#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "pymupdf",
#     "pandas",
#     "openpyxl",
#     "pypdf-table-extraction",
#     "opencv-python-headless",
#     "pypdfium2",
#     "pillow",
#     "pymupdf-fonts",
#     "pymupdf4llm",
#     "pymupdfpro",
# ]
# ///
import argparse
import sys
from pathlib import Path


def build_parser():
    p = argparse.ArgumentParser(
        description="Extract tables from a PDF to CSV or Excel using PyMuPDF or Camelot."
    )
    p.add_argument("input_pdf", help="Path to input PDF")
    p.add_argument("-o", "--output", required=True, help="Output file or directory")
    p.add_argument(
        "-e",
        "--engine",
        choices=["pymupdf", "camelot"],
        default="pymupdf",
        help="Extraction engine to use",
    )
    p.add_argument(
        "-f",
        "--format",
        choices=["csv", "xlsx"],
        default="csv",
        help="Output format",
    )
    p.add_argument(
        "-p",
        "--pages",
        default="all",
        help='Pages to parse, e.g. "all", "1", "1,3,5", "1-3"',
    )
    p.add_argument(
        "--flavor",
        choices=["lattice", "stream"],
        default="lattice",
        help="Camelot flavor; ignored for PyMuPDF",
    )
    p.add_argument(
        "--password",
        default=None,
        help="PDF password if needed",
    )
    p.add_argument(
        "--combine",
        action="store_true",
        help="Combine all extracted tables into one file per output format",
    )
    p.add_argument(
        "--prefix",
        default="table",
        help="Prefix for generated CSV files or Excel sheet names",
    )
    return p


def ensure_parent(path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)


def normalize_output_path(output: Path, fmt: str, combine: bool) -> Path:
    if fmt == "csv" and not combine:
        output.mkdir(parents=True, exist_ok=True)
        return output
    ensure_parent(output)
    return output


def extract_with_pymupdf(input_pdf: str, pages: str, password=None):
    try:
        import fitz
    except ImportError:
        sys.exit("PyMuPDF not installed. Install with: pip install pymupdf pandas openpyxl")

    doc = fitz.open(input_pdf)
    if doc.needs_pass:
        if not password or not doc.authenticate(password):
            sys.exit("PDF is password-protected and authentication failed.")

    selected = []
    if pages == "all":
        selected = list(range(len(doc)))
    else:
        parts = [x.strip() for x in pages.split(",") if x.strip()]
        for part in parts:
            if "-" in part:
                a, b = part.split("-", 1)
                selected.extend(range(int(a) - 1, int(b)))
            else:
                selected.append(int(part) - 1)
        selected = sorted(set(i for i in selected if 0 <= i < len(doc)))

    tables = []
    for page_index in selected:
        page = doc[page_index]
        found = page.find_tables()
        for table_index, table in enumerate(found.tables, start=1):
            try:
                df = table.to_pandas()
            except Exception:
                data = table.extract()
                import pandas as pd
                df = pd.DataFrame(data)
            tables.append({
                "page": page_index + 1,
                "table": table_index,
                "df": df,
            })
    return tables


def extract_with_camelot(input_pdf: str, pages: str, flavor: str, password=None):
    try:
        import camelot
    except ImportError:
        try:
            import pypdf_table_extraction as camelot
        except ImportError:
            sys.exit(
                "Camelot not installed. Install with: pip install pypdf-table-extraction pandas openpyxl"
            )

    kwargs = {"pages": pages, "flavor": flavor}
    if flavor == "lattice":
        # Lattice rasterizes each page; use the self-contained pypdfium2
        # backend so no system Ghostscript install is required.
        kwargs["backend"] = "pdfium"
    if password:
        kwargs["password"] = password
    found = camelot.read_pdf(input_pdf, **kwargs)
    tables = []
    for idx, table in enumerate(found, start=1):
        page = getattr(table, "page", None)
        try:
            page_num = int(str(page).split(",")[0]) if page else None
        except Exception:
            page_num = None
        tables.append({
            "page": page_num,
            "table": idx,
            "df": table.df,
        })
    return tables


def write_csv_tables(tables, output: Path, prefix: str, combine: bool):
    import pandas as pd

    written = []
    if combine:
        combined_rows = []
        for t in tables:
            df = t["df"].copy()
            df.insert(0, "source_table", t["table"])
            df.insert(0, "source_page", t["page"])
            combined_rows.append(df)
        if not combined_rows:
            sys.exit("No tables found.")
        out_file = output if output.suffix.lower() == ".csv" else output.with_suffix(".csv")
        ensure_parent(out_file)
        pd.concat(combined_rows, ignore_index=True).to_csv(out_file, index=False)
        written.append(out_file)
    else:
        output.mkdir(parents=True, exist_ok=True)
        if not tables:
            sys.exit("No tables found.")
        for t in tables:
            out_file = output / f"{prefix}_p{t['page'] or 'na'}_t{t['table']}.csv"
            t["df"].to_csv(out_file, index=False)
            written.append(out_file)
    return written


def write_xlsx_tables(tables, output: Path, prefix: str, combine: bool):
    import pandas as pd

    if not tables:
        sys.exit("No tables found.")
    out_file = output if output.suffix.lower() == ".xlsx" else output.with_suffix(".xlsx")
    ensure_parent(out_file)
    with pd.ExcelWriter(out_file, engine="openpyxl") as writer:
        if combine:
            combined_rows = []
            for t in tables:
                df = t["df"].copy()
                df.insert(0, "source_table", t["table"])
                df.insert(0, "source_page", t["page"])
                combined_rows.append(df)
            pd.concat(combined_rows, ignore_index=True).to_excel(writer, sheet_name="combined", index=False)
        else:
            for idx, t in enumerate(tables, start=1):
                sheet = f"{prefix}_{idx}"[:31]
                t["df"].to_excel(writer, sheet_name=sheet, index=False)
    return [out_file]


def main():
    args = build_parser().parse_args()
    input_pdf = Path(args.input_pdf)
    output = Path(args.output)

    if not input_pdf.exists():
        sys.exit(f"Input PDF not found: {input_pdf}")

    normalize_output_path(output, args.format, args.combine)

    if args.engine == "pymupdf":
        tables = extract_with_pymupdf(str(input_pdf), args.pages, args.password)
    else:
        tables = extract_with_camelot(str(input_pdf), args.pages, args.flavor, args.password)

    if args.format == "csv":
        written = write_csv_tables(tables, output, args.prefix, args.combine)
    else:
        written = write_xlsx_tables(tables, output, args.prefix, args.combine)

    for path in written:
        print(path)


if __name__ == "__main__":
    main()