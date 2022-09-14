#!/usr/bin/perl
#
# xStation Image Renamer v1.1
# Written by Derek Pascarella (ateam)
#
# A utility to rename CUE/BIN files to reflect folder name, as to customize game list as
# it appears in xStation's menu.

# Include necessary modules.
use strict;
use Cwd 'abs_path';
use File::Basename;
use File::Find::Rule;
use Time::HiRes 'time';

# Define input variables.
my $sd_path_source = $ARGV[0];

# Define/initialize variables.
my @sd_folders = ();
my @sd_folders_with_files = ();
my $sd_folders_with_files_count = 0;
my $count_success = 0;
my $count_fail_cue = 0;
my $count_fail_bin = 0;

# Path to source SD card is missing.
if(!defined $sd_path_source || $sd_path_source eq "")
{
	&show_error("ERROR: Must specify source SD card path as first argument.");
}
# Path to source SD card doesn't exist.
elsif(!-e $sd_path_source)
{
	&show_error("ERROR: Source SD card path \"" . $sd_path_source . "\" does not exist.");
}
# Path to source SD card is not readable.
elsif(!-R $sd_path_source)
{
	&show_error("ERROR: Source SD card path \"" . $sd_path_source . "\" is not readable.");
}
# Path to source SD card is not a folder.
elsif(-f $sd_path_source)
{
	&show_error("ERROR: Source SD card path \"" . $sd_path_source . "\" is a file, not a folder.");
}

# Recursively store list of all folders/subfolders.
my $sd_folder_rule = File::Find::Rule->new;
$sd_folder_rule->directory;
$sd_folder_rule->not_name(".");
$sd_folder_rule->not_name("..");
$sd_folder_rule->not_name("00xstation");
@sd_folders = $sd_folder_rule->in($sd_path_source);

# Iterate through all folders and subfolders, building array of those that contain files.
foreach(@sd_folders)
{
	# Store contents of current folder.
	my $sd_subfolder_rule = File::Find::Rule->new;
	$sd_subfolder_rule->file;
	$sd_subfolder_rule->maxdepth(1);
	my @sd_subfolder_files = $sd_subfolder_rule->in($_);

	# Folder contains files, so add it to array.
	if(scalar(@sd_subfolder_files) > 0)
	{
		push(@sd_folders_with_files, $_);
	}
}

# SD card path contains no folders with files.
if(scalar(@sd_folders_with_files) == 0)
{
	&show_error("ERROR: Source SD card path \"" . $sd_path_source . "\" has no folders containing files.");
}

# Print program information.
print "\nxStation Image Renamer v1.1\n";
print "Written by Derek Pascarella (ateam)\n\n";
print "This program will process Redump-formatted CUE/BIN disc images\n";
print "stored in separate folders within the following location:\n\n";
print "> " . abs_path($sd_path_source) . "\n\n";
print "A total of " . scalar(@sd_folders_with_files) . " folder(s) were found.\n\n";
print "Proceed? (Y/N) ";

# Store prompt input.
chop(my $proceed = <STDIN>);

# Exit if user chose not to proceed.
if(uc($proceed) ne "Y")
{
	print "\n";
	exit;
}

# Store start time.
my $start_time = Time::HiRes::gettimeofday();

# Print status message.
print "\n> Processing xStation SD card...\n\n";

# Iterate through each subfolder for processing.
foreach my $sd_subfolder (@sd_folders_with_files)
{
	# Define/initialize variables.
	my $sd_subfolder_cue;

	# Store base folder name as game name.
	my $game_name = basename($sd_subfolder);

	# Print status message.
	print "> " . $game_name . "\n";
	print "  -Location: " . abs_path($sd_subfolder) . "\n";
	print "  -Found CUE: ";

	# Store list of all files in subfolder.
	my $sd_subfolder_rule = File::Find::Rule->new;
	$sd_subfolder_rule->file;
	$sd_subfolder_rule->maxdepth(1);
	my @sd_subfolder_files = $sd_subfolder_rule->in($sd_subfolder);

	# Iterate through subfolder to locate CUE file.
	foreach(@sd_subfolder_files)
	{
		(my $name, my $path, my $suffix) = fileparse($_, qr"\..[^.]*$");

		if(lc($suffix) eq ".cue")
		{
			$sd_subfolder_cue = basename($_);
		}
	}

	# CUE file was found, proceed.
	if($sd_subfolder_cue ne "")
	{
		print "Yes\n";
		print "  -CUE filename: $sd_subfolder_cue\n";
	}
	# Otherwise, skip to next subfolder.
	else
	{
		print "No\n\n";

		# Increase CUE failure count by one.
		$count_fail_cue ++;

		next;
	}

	# Read contents of CUE sheet.
	my $sd_subfolder_cue_contents = &read_file($sd_subfolder . "/" . $sd_subfolder_cue);

	# Parse CUE and build array of BINs.
	my @sd_subfolder_tracks = $sd_subfolder_cue_contents =~ /FILE\s"(.*?)"/gm;
	my @sd_subfolder_bins = ();

	foreach(@sd_subfolder_tracks)
	{
		(my $name, my $path, my $suffix) = fileparse($_, qr"\..[^.]*$");

		if(lc($suffix) eq ".bin")
		{
			push(@sd_subfolder_bins, basename($_));
		}
	}

	# Print status message.
	print "  -Found BINs: ";

	# One or more BIN files were found, proceed.
	if(scalar(@sd_subfolder_bins) > 0)
	{
		print "Yes (" . scalar(@sd_subfolder_bins) . " total)\n";
	}
	# Otherwise, skip to next subfolder.
	else
	{
		print "No\n\n";

		# Increase BIN failure count by one.
		$count_fail_bin ++;

		next;
	}

	# Print status message.
	print "  -Renaming CUE: " . $game_name . ".cue\n";
	rename($sd_subfolder . "/" . $sd_subfolder_cue, $sd_subfolder . "/" . $game_name . ".cue");

	# Print status message.
	print "  -Renaming BINs: ";

	# Only one BIN file found, process accordingly.
	if(scalar(@sd_subfolder_bins) == 1)
	{
		# Store original and new BIN filename.
		my $sd_subfolder_bin = basename($sd_subfolder_bins[0]);
		my $sd_subfolder_bin_new = $game_name . ".bin";

		# Modify CUE sheet.
		$sd_subfolder_cue_contents =~ s/\Q$sd_subfolder_bin/$sd_subfolder_bin_new/g;

		# Rename single BIN file.
		rename($sd_subfolder . "/" . $sd_subfolder_bin, $sd_subfolder . "/" . $sd_subfolder_bin_new);

		# Print status message.
		print "Done\n";
	}
	# Otherwise, process multiple BIN files.
	else
	{
		# Start BIN track count at zero.
		my $track_number = 0;

		# Iterate through each BIN file.
		foreach my $sd_subfolder_bin (@sd_subfolder_bins)
		{
			# Store original BIN filename.
			$sd_subfolder_bin = basename($sd_subfolder_bin);

			# Begin building new BIN filename.
			my $sd_subfolder_bin_new = $game_name . " (Track ";

			# Increase track number by one.
			$track_number ++;

			# Append track number to filename.
			if($track_number < 10)
			{
				$sd_subfolder_bin_new .= "0" . $track_number;
			}
			else
			{
				$sd_subfolder_bin_new .= $track_number;
			}

			# Finish generating new BIN filename.
			$sd_subfolder_bin_new .= ").bin";

			# Rename BIN file.
			rename($sd_subfolder . "/" . $sd_subfolder_bin, $sd_subfolder . "/" . $sd_subfolder_bin_new);

			# Modify CUE sheet.
			$sd_subfolder_cue_contents =~ s/\Q$sd_subfolder_bin/$sd_subfolder_bin_new/g;
		}

		# Print status message.
		print "Done\n";
	}

	# Print status message.
	print "  -Updating CUE: ";

	# Write updated CUE sheet.
	&write_file($sd_subfolder . "/" . $game_name . ".cue", $sd_subfolder_cue_contents);

	# Print status message.
	print "Done\n\n";

	# Increase count of disc images processed by one.
	$count_success ++;
}

# Store stop time.
my $stop_time = Time::HiRes::gettimeofday();

# Print status message.
print "> Disc image renaming complete!\n\n";

# Print final status message.
print "Disc images processed: " . $count_success . "\n";
print "Ignored for no CUE:    " . $count_fail_cue . "\n";
print "Ignored for no BINs:   " . $count_fail_bin . "\n";
printf "Processing time:       %.2f seconds\n\n", $stop_time - $start_time;

# Subroutine to throw a specified exception.
#
# 1st parameter - Error message with which to throw exception.
sub show_error
{
	my $error = $_[0];

	die "\nxStation Image Renamer v1.1\nWritten by Derek Pascarella (ateam)\n\n$error\n\nUSAGE: xstation_renamer <PATH_TO_SD_CARD>\n\n";
}

# Subroutine to read a specified file.
#
# 1st parameter - File to read.
sub read_file
{
	my ($filename) = @_;

	open my $in, '<:encoding(UTF-8)', $filename or die "Could not open '$filename' for reading $!";
	local $/ = undef;
	my $all = <$in>;
	close $in;

	return $all;
}

# Subroutine to write data to a specified file.
#
# 1st parameter - File to write.
# 2nd parameter - Data to write.
sub write_file
{
	my ($filename, $content) = @_;

	open my $out, '>:encoding(UTF-8)', $filename or die "Could not open '$filename' for writing $!";;
	print $out $content;
	close $out;

	return;
}