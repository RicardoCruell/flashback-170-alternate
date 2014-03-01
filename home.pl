#!/usr/bin/env perl

use strict;
use warnings;

use Template;
use CGI;
use DBI;
use Date::Parse;

sub thisyear {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                    localtime(time);
    return 1900+$year;
}

my $db_location = "./db/fb.sqlite";

my $dbh = DBI->connect("dbi:SQLite:dbname=".$db_location, 
                        undef, 
                        undef, 
                        { sqlite_unicode => 1});

my $cgi = CGI->new;

my $tt = Template->new({
        INCLUDE_PATH => './templates',
        INTERPOLATE => 1,
}) or die($!);

my $user_id = $cgi->cookie('user_id');
#my $query = $cgi->param('query');

my $statement = $dbh->prepare("SELECT memory_name, image_url, age_range FROM memories
                                 WHERE user_id = ?");

$statement->execute(($user_id)) or die $statement->errstr;

my @images;

my @data;
while (@data = $statement->fetchrow_array) {
    push @images, { name => $data[0], url => $data[1], age_range => $data[2] };
}

my $age_range = "";
print STDERR "user_id: $user_id\n";
my $bday_statement = $dbh->prepare("SELECT birthday FROM users
                                 WHERE rowid = ?");

$bday_statement->execute(($user_id)) or die $bday_statement->errstr;

my $birthday;
while (@data = $bday_statement->fetchrow_array) {
    $birthday = $data[0]; 
    my $birthyear = substr($birthday, -4);

    #print STDERR "this year: " . thisyear() . "\n";
    #print STDERR "birth year: " . $birthyear . "\n";
    my $diff = thisyear() - $birthyear;

    if ($diff < 20) {
        $age_range = "youth"; 
    }
    elsif ($diff < 30) {
        $age_range = "20s"; 
    }
    elsif ($diff < 40) {
        $age_range = "30s"; 
    }
    elsif ($diff < 50) {
        $age_range = "40s"; 
    }
    elsif ($diff < 60) {
        $age_range = "50s"; 
    }
    elsif ($diff < 70) {
        $age_range = "60s"; 
    }
    elsif ($diff < 80) {
        $age_range = "70s"; 
    }
    else {
        $age_range = "80s"; 
    }

    #print STDERR "age_range: $diff\n";
}

if ($age_range eq "") {
    #print STDERR "default to youth\n";
    $age_range = "youth";
}

my $selected_image;
if ((scalar @images) > 0) {
    my $rand_int = int(rand(scalar @images));
    $selected_image = $images[$rand_int]; 
}

print $cgi->header;
$tt->process('home.html', 
                {   image => defined $selected_image ? $selected_image : undef,
                    age_range => $age_range })
    or die($!);
