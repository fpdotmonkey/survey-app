# frozen_string_literal: true

require 'date'

require 'sinatra'
require 'rom-sql'
require 'rom-repository'

# ROM::Configuration.new(:sql, 'sqlite::memory', { readonly: true })

rom = ROM.container(:sql, 'sqlite::memory') do |config|
  config.default.create_table(:survey_results) do
    primary_key :id
    column :timestamp, DateTime
    column :with_whom_you_spent_the_day, Integer
    column :weather, Integer
    column :sleep_hours, Float
    column :work_hours, Float
    column :sport_satisfaction, Integer
    column :hobby_satisfaction, Integer
    column :social_satisfaction, Integer
    column :health, Integer
    column :mood, Integer
  end

  config.default.create_table(:users) do
    primary_key :id
    column :name, String
  end

  config.relation(:survey_results) do
    schema(infer: true) do
      associations do
        belongs_to :user
      end
    end
  end

  config.relation(:users) do
    schema(infer: true) do
      associations do
        has_many :survey_results
      end
    end
  end
end

class SurveyResultRepo < ROM::Repository[:survey_results]
  def add_result(result)
    survey_results.command(:create).call(result)
  end

  def query(conditions)
    survey_results.where(conditions)
  end

  def by_id(id)
    survey_results.by_pk(id).one!
  end
end

survey_result_repo = SurveyResultRepo.new(rom)

survey_result_repo.add_result(
  timestamp: DateTime.new(2012, 12, 12, 12, 12),
  with_whom_you_spent_the_day: 1,
  weather: 1,
  sleep_hours: 1.0,
  work_hours: 1.0,
  sport_satisfaction: 1,
  hobby_satisfaction: 1,
  social_satisfaction: 1,
  health: 1,
  mood: 1
)

print(survey_result_repo.query(weather: 1))

get "/" do
  "foo"
end
