[![Build Status](https://travis-ci.org/brunetton/travel_accounts.svg?branch=master)](https://travis-ci.org/brunetton/travel_accounts)

# What's this stuff ?

The goal of this project is to easylly solve accounts problems that involve more than two persons;
typically when travelling by group.


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
    gem install zip --no-ri --no-rdoc
    gem install libxml-ruby --no-ri --no-rdoc

## Usage

### Create the LibreOffice document

In order to pass this array of datas to the program, we use an ODS (LIbreOffice calc, OpenOffice calc, ...) that containts :
  * members list
  * this array of expenses

You can open and modify the existing `sample.ods` file.

### Edit config file

You can edit config.yml to let the program to find "who paid ?", "How much ?", "For who ?" and "What for ?" coulumns.

### Lunch program and get results

    ./comptes accounts.ods

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

# Things TODO

  * Remove all French occurences in code
