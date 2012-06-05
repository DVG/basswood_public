# Welcome to the Basswood Gym Project

This is the public fork, and thus sensitive information has been removed from this repository. This was built for a local small gym owner so that he could schedule his workout classes online.

## Getting up and running

### 1. Run Bundler

```
# if you are on a fresh ruby install, first get bundler
$ gem install bundler
# skip production unless you have MySQL on your local machine
$ bundle install --without production
```

### 2. Create the development and test databases
```
$ rake db:create
$ rake db:migrate
$ rake db:seed
$ rake db:test:prepare
```

### 3. Set Up SMTP

If you want the devise mailers to work, you'll have to edit the /config/environments/development.rb files with your SMTP information

### 4. Run the specs

Rspec in this project is configured to use Chromedriver as the selenium driver. If you want to just use the default firefox, remove or comment out these lines from /spec/spec_helper
```
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end
Capybara.javascript_driver = :chrome
```

When you are ready to run the specs, use
```
$ rspec
# If you have a newer version of rspec installed, you may need to use
$ bundle exec rspec
```

Guard is configured, if you want to play with the code
```
$ guard
```

### 5. Walking around the app
```
$ rails s
```

### 6. Tour

The main page is the workouts schedule. This is where users will come to see the workout schedule for the week and sign up to participate in a workout. By home page will render the current Sunday to Saturday week. By using the paging buttons the user can view other weeks, or they can access a week directly by going to:

```
Root_url/workouts/week/YYYY-MM-DD
```

A guest user can only view the workouts, and do not have access to the members list or user profiles. Registered users can join workouts, decline workouts they previously joined, view the members list, view profiles and update their own profile with a few informational fields or change their password. A trainer has the additional power to create, update and delete their own workouts. An admin has all these powers and may additional edit other users profiles and perform CRUD operations on workouts for other trainers

A admin user is created by `rake db:seed` 

```
email: example@email.com
password: secret
```

Which you can use to play around in the application

## Points of Interest

### Dates

The workout schedule page uses a standard JQuery Datepicker with the format of MM/DD/YYYY. The goal was to keep dates in this format, but keep the date stored in the rails convention of `YYYY-MM-DD`. To avoid a lot of converting back and forth, I implemented a virtual attribute on the Workout model called `show_date`. The JQuery Datepicker then updates the show_date field and the hidden workout_date field

```javascript
$("input.date_picker").datepicker(
	{
		dateFormat: "mm/dd/yy",
		altField: "#workout_date",
		altFormat: "yy-mm-dd"
	}
);
```

### Unobtrusive Javascript

I utilized UJS in the workout delete function on the workouts#index page.

```ruby
#workouts_controller.rb
def destroy
  # @workout already loaded by declarative authorization
  @workout.destroy

  respond_to do |format|
    format.html { redirect_to workouts_url, alert: 'The workout has been cancelled' }
    format.js
  end
end
```
```javascript
#destroy.js.erb
/* Eliminate the workout by fading it out */
$('#workout_<%= @workout.id %>').fadeOut();
```

### Custom Simple_Form inputs

I have two custom inputs in the project, one for the JQuery Datepicker and one for showing a preview of a users avatar if they have already uploaded one. They can be found at 

```
/app/inputs/
```

### Model Scopes

Workout contains a method-based scope for determining the workouts in a given 7-day week. 

User contains a method-based scope for returning the list of trainers, which is all trainers that have the role `:trainer` or `:admin`

### Custom RESTful controller actions

The application implements 3 custom RESTful routes for workouts. Join and Cancel allow a registered user to participate in workouts or decline participation. Quick Add allows a trainer to quickly add a Morning (6 AM), Noon or Evening (6:15 PM) workout with a maximum capacity of 10 participants. These actions add a lot of convenience for the user as they don't have to interact with any forms at all to get full functionality out of the application.

### Specification by Example

The controller, model and request specifications in the project represent the living documentation for the Basswood Gym project. If you want any more information on what the system does, the best way to find out is by running the specs and viewing the output. I fully believe in the importance of tests and using tests to specify a system rather than just to check it after it's been built.
