require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Concerts', accepts: :json, returns: :json do
  has_attribute :where, String
  has_attribute :year, Integer, can_be_nil: true

  get '/concerts', array: true do
    request 'Get the list of concerts' do
      respond_with :ok do |concerts|
        expect(concerts.size).to be instances.count
      end
    end
  end

  get '/concerts/:id' do
    request 'Get an existing concert', id: existing(:id) do
      respond_with :ok
    end

    request 'Get an unknown concert', id: 3 do
      respond_with :not_found
    end
  end

  # Let's talk about those :id.. looks like only /concerts/2 is OK and
  # concerts/3 is not, but what we want to express is something different
  # what we mean is: if you pass the id of an existing instance then OK
  # otherwise KO. How can we do this WITHOUT depending on the instances
  # above?

  post '/concerts' do
    request 'Create a valid concert', concert: {where: 'Austin'} do
      respond_with :created do |concert|
        expect(concert['where']).to eq 'Austin'
      end
    end

    request 'Create an invalid concert', concert: {year: 2013} do
      respond_with :unprocessable_entity do |errors|
        expect(errors["where"]).to eq ["can't be blank"]
      end
    end
  end

  put '/concerts/:id' do
    request 'Update an existing concert', id: 1, concert: {year: 2011} do
      respond_with :ok do |concert|
        expect(concert["year"]).to be 2011
      end
    end

    request 'Update an unknown concert', id: 3, concert: {year: 2011} do
      respond_with :not_found
    end
  end

  delete '/concerts/:id' do
    request 'Delete an existing concert', id: 1 do
      respond_with :no_content
    end

    request 'Delete an unknown concert', id: 3 do
      respond_with :not_found
    end
  end
end