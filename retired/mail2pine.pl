#!/usr/bin/perl

# Mail2Pine
# Author: Rael Dornfest <rael@oreilly.com>
# Version: 2003-04-14

# Creates symbolic links between Mac OS X's Mail.app inboxes and
# mailboxes and Pine's mail directory (~/mail) allowing you to interleave
# Mail.app and Pine usage as the mood strikes.

my $user = $ENV{USER};
my $account_dir = "/Users/$user/Library/Mail/";
my $mailbox_dir = "/Users/$user/Library/Mail/Mailboxes";
my $mail_dir = "/Users/$user/mail";

use File::Find;

# Make a pine mail directory
-d $mail_dir or mkdir $mail_dir, 0700;

# Find and symlink Mail.app's account inboxes to ~/mail
find(\&accounts, $account_dir);

sub accounts {
    $File::Find::name =~ m!(POP-[^\/]+)/INBOX.mbox/mbox$! or return 0;

  # Symlink the INBOX  
  -e "$mail_dir/INBOX-$1" 
      or symlink($File::Find::name, "$mail_dir/INBOX-$1");

  # Symlink the Sent Messages mailbox if first account found
  -e "$mail_dir/sent-mail"
      or `ln -s "$account_dir/$1/Sent Messages.mbox/mbox" "$mail_dir/sent-mail"`;
}

# Find and symlink Mail.app's mailboxes to ~/mail
find(\&mailboxes, $mailbox_dir);

sub mailboxes {
    $File::Find::name =~ /SKindex/ and return 0;

  my($path, $mbox) = $File::Find::name =~ 
      m!^$mailbox_dir/(.*/)?([^\/]+)\.mbox/mbox!;
  
    $mbox or return 0;

  # Perform a little cleanup on paths and mbox filenames
    $path =~ s!^/|/$!!g;
    $path =~ s/[^\w\/]/_/g;
    $mbox =~ s!^/|/$!!g;
    $mbox =~ s/\W/_/g;

    $File::Find::name =~ s! !\\ !g;

  #print "$File::Find::name ~/mail/$path/$mbox\n";

    `mkdir -p $mail_dir/$path`;
  -e "$mail_dir/$path/$mbox" 
      or `ln -s $File::Find::name $mail_dir/$path/$mbox.mbox`;
}
