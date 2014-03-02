#!/usr/bin/env perl

use strict;
use warnings;

use Digest::MD5 q(md5_hex);

#system("tar -zcvf ../fb_backups/fb_backup_". md5_hex(localtime) .".tar ../../public/fb/");
system("rm -rf ../../public/fb/*");
system("cp -vR . ../../public/fb");
system("chmod o+w ../../public/fb/db/");
system("chmod o+w ../../public/fb/db/fb.sqlite");
system("chmod o+w ../../public/fb/users/");
system("rm ../../public/fb/push_live.pl");
