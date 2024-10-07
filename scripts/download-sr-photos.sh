#!/bin/bash

# This script downloads a list of images from a specific URL and saves them to a target directory.
# it was used to download Brady Gebhardt's Senior Photos from ImageQuix.
# https://shop.imagequix.com/g1001120215/photos/all
# https://shop.imagequix.com/g1001120215/photos/all/photo/rc1g8oenm6.jpg

# Define the stem URL
STEM_URL="https://api.imagequix.com/ondemand/R9N469D/gallery/1001120215/1200/"

# Define the list of image names
IMAGES=(
    "ya3cex4v39.jpg"
    "tddhjklzs4.jpg"
    "tipit3usr5.jpg"
    "8nu9gishi3.jpg"
    "5cagiy4hq9.jpg"
    "pxyjp4ksw1.jpg"
    "t3aej6a356.jpg"
    "30nmoOktgl.jpg"
    "tlwmbqb7c9.jpg"
    "jjwmzmksz5.jpg"
    "14jqibzpqz.jpg"
    "h1gs2f15e5.jpg"
    "tfn2nljmf2.jpg"
    "kl2ewguyau.jpg"
    "9hq66gqej3.jpg"
    "isnd7nwipi.jpg"
    "af2z1zf1wi.jpg"
    "rhz8fxd5dj.jpg"
    "dhtc6bkx00.jpg"
    "3gu79oizr3.jpg"
    "gbzqygyzcv.jpg"
    "b8qi4xks5h.jpg"
    "89b0u2h5sp.jpg"
    "h7zdha5o3z.jpg"
    "1dy03rcaz8.jpg"
    "3rdtsruug6.jpg"
    "yqp2ttt3ij.jpg"
    "rdxxraztr8.jpg"
    "Ovy8r32tgk.jpg"
    "spdwmhn1p7.jpg"
    "zgg5t0jjml.jpg"
    "brozphhb0i.jpg"
    "rx9pqny8ru.jpg"
    "tv8iv8nzb0.jpg"
    "pwkltba6el.jpg"
    "z9khedeemm.jpg"
    "62fc9hx5gc.jpg"
    "2qymlpk1a4.jpg"
    "p21dn4dx15.jpg"
    "suhaneqsh5.jpg"
    "pn3a29p3ax.jpg"
    "rc1g80enm6.jpg"
    "jca426xbeu.jpg"
    "3gl117gcv8.jpg"
    "46qjs7vtuz.jpg"
    "pvt1fxq1kb.jpg"
    "i38fcadwmi.jpg"
    "4rb0arjegf.jpg"
    "t7gzm4c9bh.jpg"
    "alqo62p9u3.jpg"
    "sobis1zj4n.jpg"
    "x0g7yww0zf.jpg"
    "0832w5u2oz.jpg"
    "8z376nykmy.jpg"
    "bw6nucjuzp.jpg"
    "t16ye9evzw.jpg"
    "nnxdu2echg.jpg"
    "ideyj86d7p.jpg"
    "5c5ze1vc2t.jpg"
    "e5zgmd7vr5.jpg"
    "9vo36j7ax7.jpg"
    "eqvysi73nj.jpg"
)

# Create the target directory if it doesn't exist
TARGET_DIR="$HOME/Downloads/Brady-Sr-Photos"
mkdir -p "$TARGET_DIR"

# Loop through the array of image names and download each image
for IMAGE in "${IMAGES[@]}"; do
    FULL_URL="${STEM_URL}${IMAGE}"
    curl -o "${TARGET_DIR}/${IMAGE}" "$FULL_URL"
done