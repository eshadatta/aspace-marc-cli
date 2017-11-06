## aspace-cli-ead-export

## Overview:
This is a utility script for a user to download a marcxml record.

## To get started:
- Clone repo
- Create a config.yml along the lines of the demo-config.yml.
  * Enter the appropriate username, password, and aspace uri with the backend process port
- Install ruby version 2.3.0
- Create a gemset called marc-cli which has the necessary gems for this script.
   * Example:
   * `$ rvm gemset create marc-cli`
- Install bundler
   * `gem install bundler`
- Install gems
   * `rvm gemset use marc-cli`
   * `bundle`

## Usage:
- Invoke the script and pass along the repo code and record id as parameters
  * To run without curl, a pure ruby solution
  * `ruby export-marc.rb tamwag 825`
- To run the script with curl, which should be used for large records
  * `ruby export-ead-with-curl.rb tamwag 825`
- If it runs successfully, you'll get a message:
  * Output: `EAD for record 825, repo: tamwag is available: 825.xml`

The script will save the file locally
