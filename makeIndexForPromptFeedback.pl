#!/usr/bin/perl -w 
 
#----------------------------------------------------------- 
# Name: 
#    DIOW: Digital Images On the Web
#
# Purpose: 
#    scan a directory with jp(e)g and or gif (upper or 
#    lower cases filenames ) images: create icons and 
#    create an index.html file for on line publication 
#    with icons on screen and links to original images. 
#    Useful when you have too many digital images and 
#    you do not have enough time to create web pages 
# 
# Requirements:
#    uses PERL and the convert program: best is running Linux
#
# Optional Keywords:
#   -o : means Output: name of the output HTML filename
#   -t : means Title : title of the web page
#   -c : means columnnumber: number of columns
#   -icon: means iconsize
#   -annotate: means Annotate: string to be written on the lower right corner of each image
#
# Examples:
#    chmod 755 diow.pl
#    ln -s diow.pl diow 
#    diow
#    diow -t 'My Images From Versailles, Sept-2000'
#    diow -o versailles.html
#    diow -o versailles.html -t 'My Images From Versailles, Aug-2000'
#    diow -o versailles.html -t 'My Images From Versailles, Aug-2000' -c 5 -ico 40
#    diow -o versailles.html -t 'My Images From Versailles, Aug-2000' -c 5 -ico 40 -annotate 'Versailles Aug-2000'
#
# Informations:
#    http://mips.as.arizona.edu/~hdole/diow/
#    http://wwwfirback.ias.u-psud.fr/users/dole/diow/
#    Herve Dole
#
# Modification History: 
#    ??-Original program: hj.pl by Matthew Kenworthy, UoA    
#    01-Aug-2000 This version Written by Herve Dole, IAS Orsay
#    02-Aug-2000 add -o and -t HD, IAS
#    11-Aug-2000 add version and array with legend v1.2 HD, IAS
#    11-Aug-2000 add nice keywords processing v1.3 HD, IAS
#    17-Aug-2000 add $iconsize HD, IAS v1.4
#    23-Aug-2000 add -column -ico v1.5 HD, IAS
#    23-Aug-2000 bug corrected with UPPERCASES and sorted files v1.6 HD, IAS 
#    18-Jan-2001 add gif files processing v1.7 HD, UoA
#    03-Sep-2001 add -annotate string option + png files processing v1.8 HD, UoA
#    10-Sep-2001 fixed bug when -annotate not used v1.8.1 HD, UoA
#    16-Oct-2003 XHTML 1.0 tranistionnal complient HD v2.0
#    06-Apr-2016 Modification for the tracker DQM purpose on vocms061 (Hugo Delannoy)
#    22-Mar-2017 Modification for the Prompt Feedback plots for the Tracker DQM (Hugo Delannoy)
#
#----------------------------------------------------------- 
$diow_version = '2.0';

# Welcome message
#----------------
print("--------------------------------------------------------\n"); 
print(" DIOW v$diow_version: Digital Images On the Web (H. Dole)\n"); 
print("--------------------------------------------------------\n"); 

# Users's Data 
#------------- 
$title = 'Test';                            # default title of the page
$outhtml = 'index.html';                                 # default output HTML filename
$mytextcolor= '000000';
$mybgcolor = 'FFFFFF';
$mylinkcolor ='0000FF';   # color for unvisited links
$myvlinkcolor = 'FF00FF'; # color for visited link
$barcolor = '0000FF';     # background color for title bar
$barcolor_Strip = '0000FF';     # background color for title bar
$barcolor_Pixel = '#FF9900';     # background color for title bar
$barcolor_Tracking = '9900FF';     # background color for title bar
$nbrow = 4;               # number of rows in the table
$iconsize = 100;           # size of icons
$annotate_keyword=0;      # annotate option
$annotate_string='';      # annotate string
$annotate_font = 'helvetica'; # annotate font # helvetica
$annotate_color_font='yellow';# annotate font color
$annotate_size='20-20';    # annotate Font Size
$annotate_color_box='blue';# annotate box color

# test if there are keywords
#---------------------------
#print("  $ARGV[0] \n");

for ($i=0; $i <= $#ARGV; $i++){
# -t 'title of the HTML page'
#----------------------------
  if ($ARGV[$i] =~ /^-t/) {$title = $ARGV[$i +1]; }
# -o output.html
#---------------
  elsif ($ARGV[$i] =~ /^-o/) {$outhtml=$ARGV[$i +1]; }
# -c 5: integer: number of rows
#------------------------------
  elsif ($ARGV[$i] =~ /^-c/) {$nbrow=$ARGV[$i +1]; }
# -icon 70: integer: size of icons
#------------------------------
  elsif ($ARGV[$i] =~ /^-icon/) {$iconsize=$ARGV[$i +1]; }
# -annotate 'My Name': string: annotation in the Images
#------------------------------------------------------
  elsif ($ARGV[$i] =~ /^-anno/) {$annotate_string=$ARGV[$i +1];
			   $annotate_keyword=1; }
}

# Print Some Argumenst to Check
print("  title : $title \n");
print("  output: $outhtml \n"); 
print("  nb rows: $nbrow \n"); 
print("  icon size: $iconsize \n"); 
if ($annotate_keyword==1) {
print("  annotate: $annotate_string \n");
print("  ann. font size: $annotate_size \n");
}
print("-------------------------\n"); 

#first get a listing of the current directory, warts and all 
opendir THISDIR, "." or die "Whoa! Current directory cannot be opened.."; 
 
# the regexp looks for either .jpg or .jpeg at the end of a filename. 
# () means group it together, \. is an escaped period, e? means 0 or 1  
# occurences of the letter e and $ means look for it at the end of the  
# filename 
# the i appended after the slash means ignore the case. 
# Look for jpg and gif and png files
#@allfiles_raw1 = grep /(\.jpe?g)$/i, readdir THISDIR; Only jpg
#@allfiles_raw = grep /(\.jpe?g)$/i||/(\.gif)$/i, readdir THISDIR; Only jpg+gif
@allfiles_raw = grep /(\.jpe?g)$/i||/(\.gif)$/i||/(\.png)$/i, readdir THISDIR;
@allfiles_Strip = grep /Strip/ ,@allfiles_raw;
@allfiles_Pixel = grep /Pixel/ ,@allfiles_raw;
@allfiles_Tracking = grep /Tracking/ ,@allfiles_raw;
@allfiles_Strip_1D = grep {$_!~/_run_|_ref_/i} @allfiles_Strip;
@allfiles_Strip_2D = grep /(_run_|_ref_)/, @allfiles_Strip;
@allfiles_Pixel_1D = grep {$_!~/_run_|_ref_/i} @allfiles_Pixel;
@allfiles_Pixel_2D = grep /(_run_|_ref_)/, @allfiles_Pixel;
@allfiles_Tracking_1D = grep {$_!~/_run_|_ref_/i} @allfiles_Tracking;
@allfiles_Tracking_2D = grep /(_run_|_ref_)/, @allfiles_Tracking;


#foreach $file_1D (@allfiles_raw_1D) {
#         print("list... $file_1D\n");
#}
#foreach $file_2D (@allfiles_raw_2D) {
#         print("list... $file_2D\n");
#}

closedir THISDIR;


opendir THISDIR, "." or die "Whoa! Current directory cannot be opened.."; 
@rootfiles_raw = grep /(\.root)$/i, readdir THISDIR;
closedir THISDIR; 

opendir THISDIR, "." or die "Whoa! Current directory cannot be opened.."; 
@pdffiles_raw = grep /(\.pdf)$/i, readdir THISDIR;
closedir THISDIR; 

opendir THISDIR, "." or die "Whoa! Current directory cannot be opened.."; 
@txtfiles_raw = grep /(\.txt)$/i, readdir THISDIR;
closedir THISDIR; 


# Sort files
#-----------
@allfiles = sort @allfiles_raw ;
@allfiles = @allfiles_raw ; #Don't sort it this time!
@allfiles_1D = @allfiles_raw_1D ; #Don't sort it this time!
@allfiles_2D = @allfiles_raw_2D ; #Don't sort it this time!
@rootfiles = sort @rootfiles_raw ;
@pdffiles = sort @pdffiles_raw ;
@txtfiles = sort @txtfiles_raw ;

open(HTMLFILE,">$outhtml") or die "Can't open $outhtml for writing"; 

print HTMLFILE "<?xml version=\"1.0\" encoding=\"iso-8859-1\" ?>"; 
print HTMLFILE "<!DOCTYPE html "; 
print HTMLFILE "     PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\""; 
print HTMLFILE "     \"DTD/xhtml1-transitional.dtd\">"; 
print HTMLFILE "<html>\n"; 
print HTMLFILE "<head>\n"; 
print HTMLFILE "<title>$title</title>\n"; 
print HTMLFILE "</head>\n"; 
print HTMLFILE "<body text=\"#$mytextcolor\" bgcolor=\"#$mybgcolor\" link=\"#$mylinkcolor\" vlink=\"#$myvlinkcolor\">\n"; 

print HTMLFILE "<table align=\"center\"><tbody>\n"; 
print HTMLFILE "<tr>\n"; 
print HTMLFILE "<td align=\"center\" width=\"40%\" bgcolor=\"#$barcolor\">\n";  
print HTMLFILE "<font color=\"#FFFFFF\" size=\"+1\" face=\"Helvetica\"> <b> $title </b> </font><br />\n";  
print HTMLFILE "</td>\n"; 
print HTMLFILE "</tr>\n"; 
print HTMLFILE "</tbody>\n"; 
print HTMLFILE "</table>\n"; 
print HTMLFILE "<br />\n"; 

#Step 0: Print conditions
# open the file for processing
$outFileName = "/afs/cern.ch/user/c/cctrack/scratch0/Shifter_scripts/PromptFeedback/conditions.txt";
open($outFile, '<', $outFileName) or die "Unable to open file for reading : $!";

# iterate through each line in the file
while ( $line = <$outFile> )
{
    # print the individual line
    print HTMLFILE "$line\n";
}

# close the file
close $outFile;
print HTMLFILE "<br />\n"; 

#First: Strip TH1 plots
if(scalar @allfiles_Strip_1D > 0){
    print HTMLFILE "<table align=\"center\"><tbody>\n"; 
    print HTMLFILE "<tr>\n"; 
    print HTMLFILE "<td align=\"center\" width=\"40%\" bgcolor=\"#$barcolor_Strip\">\n";  
    print HTMLFILE "<font color=\"#FFFFFF\" size=\"+1\" face=\"Helvetica\"> <b> SiStrip 1D plots </b> </font><br />\n";  
    print HTMLFILE "</td>\n"; 
    print HTMLFILE "</tr>\n"; 
    print HTMLFILE "</tbody>\n"; 
    print HTMLFILE "</table>\n"; 
    print HTMLFILE "<br />\n"; 
    
    # Create Table of Images
    #-----------------------
    print HTMLFILE " \n"; 
    print HTMLFILE " \n"; 
    print HTMLFILE "<table align=\"center\" border=\"1\" cellpadding=\"5\" cellspacing=\"2\">\n"; 
    
    # Loop on images
    #---------------
    $count = 0;
    $prefix = ' ';
    $suffix = ' ';
    foreach $jpegfile (@allfiles_Strip_1D) { 
    # select jpg or jpeg file 
    	print("Working on... $jpegfile\n"); 
    # Annotate Option: Create FineName
    #---------------------------------
    	$annotatejpegfile = $jpegfile;
    	#$rootfile = $jpegfile;
    	#$rootfile =~ s/.png/.root/;
    # new name for lowercase filenames jpg
    	$annotatejpegfile =~ s/.jpe?g/_ann.jpg/; 
    # new name for uppercase filenames jpg
    	$annotatejpegfile =~ s/.JPE?G/_ann.jpg/; 
    # new name for lowercase filenames png
    	$annotatejpegfile =~ s/.png/_ann.png/; 
    # new name for uppercase filenames png
    	$annotatejpegfile =~ s/.PNG/_ann.png/; 
    # new name for lowercase filenames gif
    	$annotatejpegfile =~ s/.gif/_ann.gif/; 
    # new name for uppercase filenames gif
    	$annotatejpegfile =~ s/.GIF/_ann.gif/; 
    # Annotate Processing
    	if ($annotate_keyword == 1) {
    #	  print ("$annotate_string \n");
    #	  system("convert -gravity SouthEast -font '-*-$annotate_font-*-*-*--$annotate_size-*-*-*-*-iso8859-1' -fill $annotate_color_font -box $annotate_color_box -draw \'text 10,30 \"$annotate_string\"\' $jpegfile $annotatejpegfile"); # beware: 20 (in text argument) must be >~ to $annotate_size+10
    	  system("convert -gravity SouthEast -font '-*-$annotate_font-*-*-*--$annotate_size-*-*-*-*-iso8859-1' -fill $annotate_color_font -box $annotate_color_box -draw \'text 10,30 \"$annotate_string\"\' $jpegfile $annotatejpegfile"); # beware: 20 (in text argument) must be >~ to $annotate_size
    	} else {
    	  $annotatejpegfile = $jpegfile
    	}
    
    # xlsfonts -fn '*-0-0-0-0-*' to check the available fonts on your system
    
    # insert in the HTML code the image and its icon
    #-----------------------------------------------
    	$prefix = ' ';
    	$suffix = ' ';
    	if ($count == $nbrow-1 ) {
    	  $prefix = ' ';
    	  $suffix = '</tr>';
    	  $count = -1;
    	}
    	if ($count == 0 ) {
    	  $prefix = '<tr>';
    	  $suffix = ' ';
    	}
    	$string = "$prefix <td align=\"center\"> <a href=\"" . $annotatejpegfile . "\"><img src=\"" . $jpegfile . "\" height=\"260\" width=\"600\" hspace=\"5\" vspace=\"5\" border=\"0\" alt=\"$jpegfile\" /></a> \n  <br /> $annotatejpegfile </td> $suffix \n"; 
    	print HTMLFILE $string;
    	#$string1 
    	$count +=  1;
        }
    
    
    # End table
    #----------
    print HTMLFILE "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100\%\">\n";
    print HTMLFILE "<br />\n"; 
    print HTMLFILE "<br />\n"; 
}

#Second: Strip TH2 plots
if(scalar @allfiles_Strip_2D >0){
    print HTMLFILE "<table align=\"center\"><tbody>\n"; 
    print HTMLFILE "<tr>\n"; 
    print HTMLFILE "<td align=\"center\" width=\"40%\" bgcolor=\"#$barcolor_Strip\">\n";  
    print HTMLFILE "<font color=\"#FFFFFF\" size=\"+1\" face=\"Helvetica\"> <b> SiStrip 2D plots (run on left, ref on right) </b> </font><br />\n";  
    print HTMLFILE "</td>\n"; 
    print HTMLFILE "</tr>\n"; 
    print HTMLFILE "</tbody>\n"; 
    print HTMLFILE "</table>\n"; 
    print HTMLFILE "<br />\n"; 
    
    # Create Table of Images
    #-----------------------
    print HTMLFILE " \n"; 
    print HTMLFILE " \n"; 
    print HTMLFILE "<table align=\"center\" border=\"1\" cellpadding=\"5\" cellspacing=\"2\">\n"; 
    
    # Loop on images
    #---------------
    $count = 0;
    $prefix = ' ';
    $suffix = ' ';
    foreach $jpegfile (@allfiles_Strip_2D) { 
    # select jpg or jpeg file 
    	print("Working on... $jpegfile\n"); 
    # Annotate Option: Create FineName
    #---------------------------------
    	$annotatejpegfile = $jpegfile;
    	#$rootfile = $jpegfile;
    	#$rootfile =~ s/.png/.root/;
    # new name for lowercase filenames jpg
    	$annotatejpegfile =~ s/.jpe?g/_ann.jpg/; 
    # new name for uppercase filenames jpg
    	$annotatejpegfile =~ s/.JPE?G/_ann.jpg/; 
    # new name for lowercase filenames png
    	$annotatejpegfile =~ s/.png/_ann.png/; 
    # new name for uppercase filenames png
    	$annotatejpegfile =~ s/.PNG/_ann.png/; 
    # new name for lowercase filenames gif
    	$annotatejpegfile =~ s/.gif/_ann.gif/; 
    # new name for uppercase filenames gif
    	$annotatejpegfile =~ s/.GIF/_ann.gif/; 
    # Annotate Processing
    	if ($annotate_keyword == 1) {
    #	  print ("$annotate_string \n");
    #	  system("convert -gravity SouthEast -font '-*-$annotate_font-*-*-*--$annotate_size-*-*-*-*-iso8859-1' -fill $annotate_color_font -box $annotate_color_box -draw \'text 10,30 \"$annotate_string\"\' $jpegfile $annotatejpegfile"); # beware: 20 (in text argument) must be >~ to $annotate_size+10
    	  system("convert -gravity SouthEast -font '-*-$annotate_font-*-*-*--$annotate_size-*-*-*-*-iso8859-1' -fill $annotate_color_font -box $annotate_color_box -draw \'text 10,30 \"$annotate_string\"\' $jpegfile $annotatejpegfile"); # beware: 20 (in text argument) must be >~ to $annotate_size
    	} else {
    	  $annotatejpegfile = $jpegfile
    	}
    
    # xlsfonts -fn '*-0-0-0-0-*' to check the available fonts on your system
    
    # insert in the HTML code the image and its icon
    #-----------------------------------------------
    	$prefix = ' ';
    	$suffix = ' ';
    	if ($count == $nbrow-1 ) {
    	  $prefix = ' ';
    	  $suffix = '</tr>';
    	  $count = -1;
    	}
    	if ($count == 0 ) {
    	  $prefix = '<tr>';
    	  $suffix = ' ';
    	}
    	$string = "$prefix <td align=\"center\"> <a href=\"" . $annotatejpegfile . "\"><img src=\"" . $jpegfile . "\" height=\"260\" width=\"600\" hspace=\"5\" vspace=\"5\" border=\"0\" alt=\"$jpegfile\" /></a> \n  <br /> $annotatejpegfile </td> $suffix \n"; 
    	print HTMLFILE $string;
    	#$string1 
    	$count +=  1;
        }
    # End table
    #----------
    print HTMLFILE "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100\%\">\n";
    print HTMLFILE "<br />\n"; 
    print HTMLFILE "<br />\n"; 
}

#Third: Pixel TH1 plots
if(scalar @allfiles_Pixel_1D > 0){
    print HTMLFILE "<table align=\"center\"><tbody>\n"; 
    print HTMLFILE "<tr>\n"; 
    print HTMLFILE "<td align=\"center\" width=\"40%\" bgcolor=\"#$barcolor_Pixel\">\n";  
    print HTMLFILE "<font color=\"#FFFFFF\" size=\"+1\" face=\"Helvetica\"> <b> Pixel 1D plots </b> </font><br />\n";  
    print HTMLFILE "</td>\n"; 
    print HTMLFILE "</tr>\n"; 
    print HTMLFILE "</tbody>\n"; 
    print HTMLFILE "</table>\n"; 
    print HTMLFILE "<br />\n"; 
    
    # Create Table of Images
    #-----------------------
    print HTMLFILE " \n"; 
    print HTMLFILE " \n"; 
    print HTMLFILE "<table align=\"center\" border=\"1\" cellpadding=\"5\" cellspacing=\"2\">\n"; 
    
    # Loop on images
    #---------------
    $count = 0;
    $prefix = ' ';
    $suffix = ' ';
    foreach $jpegfile (@allfiles_Pixel_1D) { 
    # select jpg or jpeg file 
    	print("Working on... $jpegfile\n"); 
    # Annotate Option: Create FineName
    #---------------------------------
    	$annotatejpegfile = $jpegfile;
    	#$rootfile = $jpegfile;
    	#$rootfile =~ s/.png/.root/;
    # new name for lowercase filenames jpg
    	$annotatejpegfile =~ s/.jpe?g/_ann.jpg/; 
    # new name for uppercase filenames jpg
    	$annotatejpegfile =~ s/.JPE?G/_ann.jpg/; 
    # new name for lowercase filenames png
    	$annotatejpegfile =~ s/.png/_ann.png/; 
    # new name for uppercase filenames png
    	$annotatejpegfile =~ s/.PNG/_ann.png/; 
    # new name for lowercase filenames gif
    	$annotatejpegfile =~ s/.gif/_ann.gif/; 
    # new name for uppercase filenames gif
    	$annotatejpegfile =~ s/.GIF/_ann.gif/; 
    # Annotate Processing
    	if ($annotate_keyword == 1) {
    #	  print ("$annotate_string \n");
    #	  system("convert -gravity SouthEast -font '-*-$annotate_font-*-*-*--$annotate_size-*-*-*-*-iso8859-1' -fill $annotate_color_font -box $annotate_color_box -draw \'text 10,30 \"$annotate_string\"\' $jpegfile $annotatejpegfile"); # beware: 20 (in text argument) must be >~ to $annotate_size+10
    	  system("convert -gravity SouthEast -font '-*-$annotate_font-*-*-*--$annotate_size-*-*-*-*-iso8859-1' -fill $annotate_color_font -box $annotate_color_box -draw \'text 10,30 \"$annotate_string\"\' $jpegfile $annotatejpegfile"); # beware: 20 (in text argument) must be >~ to $annotate_size
    	} else {
    	  $annotatejpegfile = $jpegfile
    	}
    
    # xlsfonts -fn '*-0-0-0-0-*' to check the available fonts on your system
    
    # insert in the HTML code the image and its icon
    #-----------------------------------------------
    	$prefix = ' ';
    	$suffix = ' ';
    	if ($count == $nbrow-1 ) {
    	  $prefix = ' ';
    	  $suffix = '</tr>';
    	  $count = -1;
    	}
    	if ($count == 0 ) {
    	  $prefix = '<tr>';
    	  $suffix = ' ';
    	}
    	$string = "$prefix <td align=\"center\"> <a href=\"" . $annotatejpegfile . "\"><img src=\"" . $jpegfile . "\" height=\"260\" width=\"600\" hspace=\"5\" vspace=\"5\" border=\"0\" alt=\"$jpegfile\" /></a> \n  <br /> $annotatejpegfile </td> $suffix \n"; 
    	print HTMLFILE $string;
    	#$string1 
    	$count +=  1;
        }
    
    
    # End table
    #----------
    print HTMLFILE "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100\%\">\n";
    print HTMLFILE "<br />\n"; 
    print HTMLFILE "<br />\n"; 
}

#Fourth: Pixel TH2 plots
if(scalar @allfiles_Pixel_2D >0){
    print HTMLFILE "<table align=\"center\"><tbody>\n"; 
    print HTMLFILE "<tr>\n"; 
    print HTMLFILE "<td align=\"center\" width=\"40%\" bgcolor=\"#$barcolor_Pixel\">\n";  
    print HTMLFILE "<font color=\"#FFFFFF\" size=\"+1\" face=\"Helvetica\"> <b> Pixel 2D plots (run on left, ref on right) </b> </font><br />\n";  
    print HTMLFILE "</td>\n"; 
    print HTMLFILE "</tr>\n"; 
    print HTMLFILE "</tbody>\n"; 
    print HTMLFILE "</table>\n"; 
    print HTMLFILE "<br />\n"; 
    
    # Create Table of Images
    #-----------------------
    print HTMLFILE " \n"; 
    print HTMLFILE " \n"; 
    print HTMLFILE "<table align=\"center\" border=\"1\" cellpadding=\"5\" cellspacing=\"2\">\n"; 
    
    # Loop on images
    #---------------
    $count = 0;
    $prefix = ' ';
    $suffix = ' ';
    foreach $jpegfile (@allfiles_Pixel_2D) { 
    # select jpg or jpeg file 
    	print("Working on... $jpegfile\n"); 
    # Annotate Option: Create FineName
    #---------------------------------
    	$annotatejpegfile = $jpegfile;
    	#$rootfile = $jpegfile;
    	#$rootfile =~ s/.png/.root/;
    # new name for lowercase filenames jpg
    	$annotatejpegfile =~ s/.jpe?g/_ann.jpg/; 
    # new name for uppercase filenames jpg
    	$annotatejpegfile =~ s/.JPE?G/_ann.jpg/; 
    # new name for lowercase filenames png
    	$annotatejpegfile =~ s/.png/_ann.png/; 
    # new name for uppercase filenames png
    	$annotatejpegfile =~ s/.PNG/_ann.png/; 
    # new name for lowercase filenames gif
    	$annotatejpegfile =~ s/.gif/_ann.gif/; 
    # new name for uppercase filenames gif
    	$annotatejpegfile =~ s/.GIF/_ann.gif/; 
    # Annotate Processing
    	if ($annotate_keyword == 1) {
    #	  print ("$annotate_string \n");
    #	  system("convert -gravity SouthEast -font '-*-$annotate_font-*-*-*--$annotate_size-*-*-*-*-iso8859-1' -fill $annotate_color_font -box $annotate_color_box -draw \'text 10,30 \"$annotate_string\"\' $jpegfile $annotatejpegfile"); # beware: 20 (in text argument) must be >~ to $annotate_size+10
    	  system("convert -gravity SouthEast -font '-*-$annotate_font-*-*-*--$annotate_size-*-*-*-*-iso8859-1' -fill $annotate_color_font -box $annotate_color_box -draw \'text 10,30 \"$annotate_string\"\' $jpegfile $annotatejpegfile"); # beware: 20 (in text argument) must be >~ to $annotate_size
    	} else {
    	  $annotatejpegfile = $jpegfile
    	}
    
    # xlsfonts -fn '*-0-0-0-0-*' to check the available fonts on your system
    
    # insert in the HTML code the image and its icon
    #-----------------------------------------------
    	$prefix = ' ';
    	$suffix = ' ';
    	if ($count == $nbrow-1 ) {
    	  $prefix = ' ';
    	  $suffix = '</tr>';
    	  $count = -1;
    	}
    	if ($count == 0 ) {
    	  $prefix = '<tr>';
    	  $suffix = ' ';
    	}
    	$string = "$prefix <td align=\"center\"> <a href=\"" . $annotatejpegfile . "\"><img src=\"" . $jpegfile . "\" height=\"260\" width=\"600\" hspace=\"5\" vspace=\"5\" border=\"0\" alt=\"$jpegfile\" /></a> \n  <br /> $annotatejpegfile </td> $suffix \n"; 
    	print HTMLFILE $string;
    	#$string1 
    	$count +=  1;
        }
    # End table
    #----------
    print HTMLFILE "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100\%\">\n";
    print HTMLFILE "<br />\n"; 
    print HTMLFILE "<br />\n"; 
}

#Fifth: Tracking TH1 plots
if(scalar @allfiles_Tracking_1D >0){
    print HTMLFILE "<table align=\"center\"><tbody>\n"; 
    print HTMLFILE "<tr>\n"; 
    print HTMLFILE "<td align=\"center\" width=\"40%\" bgcolor=\"#$barcolor_Tracking\">\n";  
    print HTMLFILE "<font color=\"#FFFFFF\" size=\"+1\" face=\"Helvetica\"> <b> Tracking 1D plots </b> </font><br />\n";  
    print HTMLFILE "</td>\n"; 
    print HTMLFILE "</tr>\n"; 
    print HTMLFILE "</tbody>\n"; 
    print HTMLFILE "</table>\n"; 
    print HTMLFILE "<br />\n"; 
    
    # Create Table of Images
    #-----------------------
    print HTMLFILE " \n"; 
    print HTMLFILE " \n"; 
    print HTMLFILE "<table align=\"center\" border=\"1\" cellpadding=\"5\" cellspacing=\"2\">\n"; 
    
    # Loop on images
    #---------------
    $count = 0;
    $prefix = ' ';
    $suffix = ' ';
    foreach $jpegfile (@allfiles_Tracking_1D) { 
    # select jpg or jpeg file 
    	print("Working on... $jpegfile\n"); 
    # Annotate Option: Create FineName
    #---------------------------------
    	$annotatejpegfile = $jpegfile;
    	#$rootfile = $jpegfile;
    	#$rootfile =~ s/.png/.root/;
    # new name for lowercase filenames jpg
    	$annotatejpegfile =~ s/.jpe?g/_ann.jpg/; 
    # new name for uppercase filenames jpg
    	$annotatejpegfile =~ s/.JPE?G/_ann.jpg/; 
    # new name for lowercase filenames png
    	$annotatejpegfile =~ s/.png/_ann.png/; 
    # new name for uppercase filenames png
    	$annotatejpegfile =~ s/.PNG/_ann.png/; 
    # new name for lowercase filenames gif
    	$annotatejpegfile =~ s/.gif/_ann.gif/; 
    # new name for uppercase filenames gif
    	$annotatejpegfile =~ s/.GIF/_ann.gif/; 
    # Annotate Processing
    	if ($annotate_keyword == 1) {
    #	  print ("$annotate_string \n");
    #	  system("convert -gravity SouthEast -font '-*-$annotate_font-*-*-*--$annotate_size-*-*-*-*-iso8859-1' -fill $annotate_color_font -box $annotate_color_box -draw \'text 10,30 \"$annotate_string\"\' $jpegfile $annotatejpegfile"); # beware: 20 (in text argument) must be >~ to $annotate_size+10
    	  system("convert -gravity SouthEast -font '-*-$annotate_font-*-*-*--$annotate_size-*-*-*-*-iso8859-1' -fill $annotate_color_font -box $annotate_color_box -draw \'text 10,30 \"$annotate_string\"\' $jpegfile $annotatejpegfile"); # beware: 20 (in text argument) must be >~ to $annotate_size
    	} else {
    	  $annotatejpegfile = $jpegfile
    	}
    
    # xlsfonts -fn '*-0-0-0-0-*' to check the available fonts on your system
    
    # insert in the HTML code the image and its icon
    #-----------------------------------------------
    	$prefix = ' ';
    	$suffix = ' ';
    	if ($count == $nbrow-1 ) {
    	  $prefix = ' ';
    	  $suffix = '</tr>';
    	  $count = -1;
    	}
    	if ($count == 0 ) {
    	  $prefix = '<tr>';
    	  $suffix = ' ';
    	}
    	$string = "$prefix <td align=\"center\"> <a href=\"" . $annotatejpegfile . "\"><img src=\"" . $jpegfile . "\" height=\"260\" width=\"600\" hspace=\"5\" vspace=\"5\" border=\"0\" alt=\"$jpegfile\" /></a> \n  <br /> $annotatejpegfile </td> $suffix \n"; 
    	print HTMLFILE $string;
    	#$string1 
    	$count +=  1;
        }
    
    
    # End table
    #----------
    print HTMLFILE "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100\%\">\n";
    print HTMLFILE "<br />\n"; 
    print HTMLFILE "<br />\n"; 
}

#Sixth: Tracking TH2 plots
if(scalar @allfiles_Tracking_2D > 0){
    print HTMLFILE "<table align=\"center\"><tbody>\n"; 
    print HTMLFILE "<tr>\n"; 
    print HTMLFILE "<td align=\"center\" width=\"40%\" bgcolor=\"#$barcolor_Tracking\">\n";  
    print HTMLFILE "<font color=\"#FFFFFF\" size=\"+1\" face=\"Helvetica\"> <b> Tracking 2D plots (run on left, ref on right) </b> </font><br />\n";  
    print HTMLFILE "</td>\n"; 
    print HTMLFILE "</tr>\n"; 
    print HTMLFILE "</tbody>\n"; 
    print HTMLFILE "</table>\n"; 
    print HTMLFILE "<br />\n"; 
    
    # Create Table of Images
    #-----------------------
    print HTMLFILE " \n"; 
    print HTMLFILE " \n"; 
    print HTMLFILE "<table align=\"center\" border=\"1\" cellpadding=\"5\" cellspacing=\"2\">\n"; 
    
    # Loop on images
    #---------------
    $count = 0;
    $prefix = ' ';
    $suffix = ' ';
    foreach $jpegfile (@allfiles_Tracking_2D) { 
    # select jpg or jpeg file 
    	print("Working on... $jpegfile\n"); 
    # Annotate Option: Create FineName
    #---------------------------------
    	$annotatejpegfile = $jpegfile;
    	#$rootfile = $jpegfile;
    	#$rootfile =~ s/.png/.root/;
    # new name for lowercase filenames jpg
    	$annotatejpegfile =~ s/.jpe?g/_ann.jpg/; 
    # new name for uppercase filenames jpg
    	$annotatejpegfile =~ s/.JPE?G/_ann.jpg/; 
    # new name for lowercase filenames png
    	$annotatejpegfile =~ s/.png/_ann.png/; 
    # new name for uppercase filenames png
    	$annotatejpegfile =~ s/.PNG/_ann.png/; 
    # new name for lowercase filenames gif
    	$annotatejpegfile =~ s/.gif/_ann.gif/; 
    # new name for uppercase filenames gif
    	$annotatejpegfile =~ s/.GIF/_ann.gif/; 
    # Annotate Processing
    	if ($annotate_keyword == 1) {
    #	  print ("$annotate_string \n");
    #	  system("convert -gravity SouthEast -font '-*-$annotate_font-*-*-*--$annotate_size-*-*-*-*-iso8859-1' -fill $annotate_color_font -box $annotate_color_box -draw \'text 10,30 \"$annotate_string\"\' $jpegfile $annotatejpegfile"); # beware: 20 (in text argument) must be >~ to $annotate_size+10
    	  system("convert -gravity SouthEast -font '-*-$annotate_font-*-*-*--$annotate_size-*-*-*-*-iso8859-1' -fill $annotate_color_font -box $annotate_color_box -draw \'text 10,30 \"$annotate_string\"\' $jpegfile $annotatejpegfile"); # beware: 20 (in text argument) must be >~ to $annotate_size
    	} else {
    	  $annotatejpegfile = $jpegfile
    	}
    
    # xlsfonts -fn '*-0-0-0-0-*' to check the available fonts on your system
    
    # insert in the HTML code the image and its icon
    #-----------------------------------------------
    	$prefix = ' ';
    	$suffix = ' ';
    	if ($count == $nbrow-1 ) {
    	  $prefix = ' ';
    	  $suffix = '</tr>';
    	  $count = -1;
    	}
    	if ($count == 0 ) {
    	  $prefix = '<tr>';
    	  $suffix = ' ';
    	}
    	$string = "$prefix <td align=\"center\"> <a href=\"" . $annotatejpegfile . "\"><img src=\"" . $jpegfile . "\" height=\"260\" width=\"600\" hspace=\"5\" vspace=\"5\" border=\"0\" alt=\"$jpegfile\" /></a> \n  <br /> $annotatejpegfile </td> $suffix \n"; 
    	print HTMLFILE $string;
    	#$string1 
    	$count +=  1;
        }
    
    
    
    # End table
    #----------
    print HTMLFILE "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100\%\">\n";
    print HTMLFILE "<br />\n"; 
    print HTMLFILE "<br />\n"; 
}



































# End HTML file
#--------------
if ($count != 0 ) {
  print HTMLFILE "</tr>\n";
}
print HTMLFILE "</table>\n";

print(" root files now.\n");
 
print HTMLFILE "<br />";

foreach $txt (@txtfiles) {
    print("Working on... $txt\n"); 
    print HTMLFILE "<a href=\"$txt\">$txt </a> <br />"; 
} 

foreach $root (@rootfiles) {
    print("Working on... $root\n"); 
    print HTMLFILE "<a href=\"$root\">$root </a> <br />"; 
} 

foreach $pdf (@pdffiles) {
    print("Working on... $pdf\n"); 
    print HTMLFILE "<a href=\"$pdf\">$pdf </a> <br />"; 
} 

#foreach $pdf (@allfiles) {
#    print("Working on... $pdf\n"); 
#    print HTMLFILE "<a href=\"$pdf\">$pdf </a> <br />"; 
#} 


# End table
#----------
print HTMLFILE "<hr />\n"; 
print HTMLFILE "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100\%\">\n";




 
# Add informations: Date and DIOW URL
#------------------------------------
print HTMLFILE "<tr><td><em>\n"; 
$d=`date +'%a %d-%b-%Y %H:%M'`; 
print HTMLFILE "Created: $d \n"; 
print HTMLFILE "</em></td><td align=\"right\"><em>\n"; 

print HTMLFILE "</body>\n"; 
print HTMLFILE "</html>\n"; 

close(HTMLFILE) or die "Can't close $outhtml. Sorry."; 

# Bye message
#------------
print(" HTML INDEX CREATED.\n"); 
print("--------------------------------------------------------\n"); 

