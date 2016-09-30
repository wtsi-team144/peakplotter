#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

# Before loading custom packages, we have to add package folder to the @inc:
use lib "/nfs/team144/ds26/FunctionalAnnotation/20150505_new_tool/packages";

use BasicInformation ;
use GWAStest ;
use GetGene ;
use GetProtein ;
use GetConsequence ;
use GetMAFs ;

# Reading file line-by-line, building hash
my $input_lines = {}; # Hash with all the details
my $fields = []; # array with the fields of interets, in the proper order for printing data.
my $filename = "Temporary.csv";
my $delimiter = ",";
my $window = 500000;
while (my $line = <>){

    $line =~ s/\s//g; # Removing any whitespace
    $input_lines->{$.}->{"input"} = $line;
}

# The first step of the analyis. Builds a proper hash of all variants in the input
($input_lines, $fields) = BasicInformation::Input_cleaner($input_lines);

# Retrieve information of overlapping gene:
($input_lines, $fields) = GetGene::Gene($input_lines, $fields);

# Retrieve information of protein expressed from overlapping gene:
($input_lines, $fields) = GetProtein::Protein($input_lines, $fields);

# Retieve variant data:
($input_lines, $fields) = GetConsequence::Consequence($input_lines, $fields);

# Fetch variant frequencies where available:
($input_lines, $fields) = GetMAFs::MAFs($input_lines, $fields);

# Run a GWAS test:
($input_lines, $fields) = GWAStest::testGWAScatalog($input_lines, $window, $fields);


# For diagnostic purposes, we can dump out the data at any point:
# print Dumper($input_lines);

#
# Then we have to save the results into a csv file....
#
print do { local $" = q<",">; qq<"@{$fields}"> },"\n";
for (my $index = 1; $index <= scalar(keys %{$input_lines}); $index++){

    my $stuff = $input_lines->{$index};
    my @array = ();

    foreach my $field (@{$fields}){push (@array, $stuff->{$field})}
	s/,//g for @array;
    print do { local $" = q<",">; qq<"@array"> },"\n";
}
