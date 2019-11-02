# frozen_string_literal: true

require 'net/http'
require 'json'
require 'time'
require_relative './report_adapter'
require_relative './github_check_run_service'
require_relative './github_client'
require_relative './coverage_report'

def read_json(path)
  JSON.parse(File.read(path))
end

@event_json = read_json(ENV['GITHUB_EVENT_PATH']) if ENV['GITHUB_EVENT_PATH']
@github_data = {
  sha: ENV['GITHUB_SHA'],
  token: ENV['TOKEN'],
  owner: ENV['GITHUB_REPOSITORY_OWNER'] || @event_json.dig('repository', 'owner', 'login'),
  repo: ENV['GITHUB_REPOSITORY_NAME'] || @event_json.dig('repository', 'name')
}

@coverage_type = ENV['TYPE']
@report_path = ENV['RESULT_PATH']
puts 'RESULT_PATH'
puts @report_path
@data = { min: ENV['MIN_COVERAGE'] }

@report = CoverageReport.generate(@coverage_type, @report_path, @data)

GithubCheckRunService.new(@report, @github_data, ReportAdapter).run
