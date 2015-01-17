# Word Count Validator


I decided to build upon the Ruby/Sinatra code that the scientists provided. This is in line with solving problems with code reuse. Having mentioned that, I also have included additional gems (digest, LiterateRandomizer) in the gemfile that helped me with this challenge.

Here are my assumptions/decisions about the requirements/objective:

1. Since aliens might not be good at counting, paying attention to uppercase/lowercase letters might also be a weakness. So, I included some code that will correct aliens' letter case mistakes, giving them the benefit of the doubt.
2. I assummed that special characters (.,!,-,etc) should not be considered when counting words. So, I included uppercase/lowercase/numbers and spaces when writing the logic to determine correct count.
3. In order to deter aliens from changing original text/exclusion response, I generated a salted key using digest that is included in every GET response. In every POST request, that key needs to be included to verify validity of request. This way, there is cheating protection.
4. I used the random function (rand) included in Ruby to get a subset of words to exclude (where applicable).
5. I used the JSON format for the data since it is language-independent.
6. I assumed that POST requests should also set the Content-Type to 'application/json' as another layer to deter invalid requests.
7. I tried to include as many checks as possible in the POST request controller. Having said that, it is possible that aliens might attempt different techniques that could throw an exception. Because of these, I included a begin/rescue block to catch exceptions and send a "BAD REQUEST" response.
8. If this code was to be deployed in production, the salting word should be private by storing it in an enviroment variable.
9. The LiterateRandomizer gem generates random text that I thought it would be helpful to include for sampling text. The sample text is saved to the texts/7 file each time an HTTP GET request is sent to the server. This text will be used if it is selected as sample only from all the text files. If you would like to use LiterateRandomizer exclusively, modify app.rb appropriately.
10. I have included different tests for both valid and invalid GET and POST requests. To remove state as much as possible in these tests, I used the before(:each) hooks. For POST request tests I created two categories: one using GET response as input and another constructing input data manually for text, exclude, key, and count parameters.


## Installation

Installation assumes that you will be using Mac OS. To run the code, download/clone the repository and follow the steps below:
		#Open a terminal window and navigate to the directory where you downloaded source code
		cd /path/to/sourcecode/directory

        # You can get everything installed using
        bundle install

        # Run the server using
        chmod +x run
        ./run

        # Run the test suite via
        rspec

Please note that the code requires the bundler gem as well as Ruby 2.1.2 and RVM.

To install bundler run this command:

        gem install bundler

To install Ruby 2.1.2, run this command:
		
		rvm install 2.1.2

and then switch to Ruby 2.1.2 using this command:

		rvm use 2.1.2

If you do not have RVM installed, do so by following instructions here:

[RVM](https://rvm.io/rvm/install)



