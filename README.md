[![Build Status](https://travis-ci.org/brunetton/travel_accounts.svg?branch=master)](https://travis-ci.org/brunetton/travel_accounts)

# What's this stuff ?

The goal of this project is to easily solve accounts problems that involve more than two persons;
typically when travelling by group.

## Alternative

Since this project I discovered a super open source webapp alternative: [Splittypie](https://splittypie.com/). I prefer using Splittypie over this project for little accounts. But for complex hollidays, with many people and interractions I like to use my project with text input as it's super quick and easy to add complex transactions (transactions that doesn't concern all people in the group).

## Example

Penny, Sheldon, Leonard and Rajesh goes to Paris from romantic hollidays.

During the travel :
  * Penny paid 10€ for Sheldon to make him buy a bottle watter at airport
  * Leonard paid 50€ for the four of them for a good restaurant with good French wine
  * Penny paid 34€ for visiting the Effeil tower with herself and the boys, exepted Sheldon, who were afraid
  * Rajesh paid 3€ for Sheldon to let him pee

This expenses where recorded in an LibreOffice calc document (for an easy conversion between Euros and Dollars).
The table looks like this :

| Who paid ?   | How much ?  | What for ?                | For who ?              |
|--------------|-------------|---------------------------|------------------------|
| Penny        | 10          | watter bottle airport     | Sheldon                |
| Leonard      | 50          | good restaurant           | All                    |
| Penny        | 33          | tour effeil Visit         | Leonard, Rajesh, Penny |
| Rajesh       | 3           | toilets for Sheldon       | Sheldon                |


## Installation

### Debian
    aptitude install rubygems libxml2 libxml2-dev
    gem install rubyzip --no-ri --no-rdoc
    gem install libxml-ruby --no-ri --no-rdoc

## Usage

Expenses are given in a file. This file can be :
  * a simple text file in a defined format (.txt)
  * an OpenOffice Spreadsheet document (.ods document)

### Create the input document

Depending on file format you want to use, you can use LibreOffice calc, OpenOffice calc for spreadsheet documents, or a simple text editor for text format (more simple on a smartphone in hollydays).

You can open and modify the existing `sample.txt` or `sample.ods` files.

#### Text file example

Here is the `sample.txt` file you can find in project:

    Participants: Penny, Sheldon, Leonard, Rajesh

    ## Day 1
    - Sheldon 132 2 packbags [Leonard, Penny]
    - Leonard 32 bad restaurant
    - Penny 23 watter bottle airport [Sheldon]
    - Leonard 50 good restaurant
    ## Day 2
    - Penny 33 tour effeil Visit [Leonard, Rajesh, Penny]
    - Rajesh 3 toilets for Sheldon [Sheldon]
    - Rajesh 6,5 bus tickets
    - Leonard 43 restaurant

### Edit config file (for ODS format)

If you use ODS file, you can edit config.yml to let the program to find "who paid ?", "How much ?", "For who ?" and "What for ?" coulumns (if not using defaults values).

### Lunch program and get results

    ./comptes sample.ods

You should see a result matrix (here the result for the example) :

              Penny     Sheldon   Leonard   Rajesh
    Penny     0         0         0         0
    Sheldon   0         0         25.5      0
    Leonard   0         0         0         0
    Rajesh    19.5      0         1.0       0

This means that **a way** of solving the problem (this is not the only one !) is :
  * Sheldon gives 25.5€ to Leonard
  * Rajesh gives 19.5€ to Penny and 1€ to Leonard

Doing that,
  * Penny and Leonard (the two that globally paid more) are refund back :
    * Penny gets back 19.50€, wich is ok :
    19.50 = 10 for watter bottle airport + 22.00 (2/3 of 33 for tour effeil Visit) - 12.50 (1/4 of 50 for good restaurant)
    * Leonard gets back 26.50€, which is ok :
    26.50 = 37.50 (3/4 of 50 for good restaurant) - 11 (1/3 of 33 for tour effeil Visit)
  * Sheldon and Rajesh refund the money they were given :
    * Sheldon gives back 25.50€, which is ok :
    25.5 = 10 for watter bottle airport + 12.50 (1/4 of 50 for good restaurant) + 3 for toilts
    * Rajesh gives back 20.50€, which is ok :
    20.50 = 12.50 (1/4 of 50 for good restaurant) + 11 (1/3 of 33 for tour effeil Visit) - 3.00 of toilets for Sheldon

## A little more

### Transfers priorities order

The more the problems are large, the more they have solutions. To avoid program choosing an arbitrary solution that does not makes everybody happy, you can tell him *"what participant is the more comfortable with money transferts"*.
Of course, people in the list should be people who will have to pay at the end, it's useless to give other names.

### A little more advanced example

`sample2.ods` shows a little more advanced spreadsheet :
  * a conversion rate is used in spreadsheet. So a specific conf file `config-for-sample2.yml` is used, to say to program that the column to be used for amounts is column number 3, not number 2
  * datas are organized into two parts: day 1 and day 2
  * transfers_priorities_order is used : Leonard is the guy who is the most comfortable with bank transfers

To calculate the result, run :

    ./comptes sample2.ods -c config-sample2.yml

# Things TODO

  * Remove all French occurences in code
