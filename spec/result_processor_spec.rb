# frozen_string_literal: true

require "helper"

describe SimpleCov::ResultProcessor do
  subject(:processor) { described_class.new(result, exit_code) }

  let(:result) { SimpleCov::Result.new({}) }
  let(:exit_code) { success_code }
  let(:success_code) { SimpleCov::ExitCodes::SUCCESS }
  let(:exception_code) { SimpleCov::ExitCodes::EXCEPTION }
  let(:min_coverage_code) { SimpleCov::ExitCodes::MINIMUM_COVERAGE }
  let(:coverage_drop_code) { SimpleCov::ExitCodes::MAXIMUM_COVERAGE_DROP }

  it "returns success and writes last run result" do
    expect(SimpleCov::LastRun).to receive(:write).with(:result => {:covered_percent => 100})
    expect(processor.call).to eq(success_code)
  end

  context "some error exit code passed" do
    let(:exit_code) { exception_code }

    it "returns that code" do
      expect(processor.call).to eq(exception_code)
    end
  end

  context "low line coverage" do
    before { allow(SimpleCov).to receive(:minimum_coverage).and_return(95) }
    before { allow(result).to receive(:covered_percent).and_return(90) }

    it "reports low line coverage and doesn't write last run result" do
      expect(SimpleCov::LastRun).not_to receive(:write)

      stderr = capture_stderr { expect(processor.call).to eq(min_coverage_code) }

      expect(stderr.chomp).to eq(
        "Line coverage (90.00%) is below the expected minimum coverage (95.00%)."
      )
    end

    context "when not the final result is processed" do
      before { expect(SimpleCov).to receive(:final_result_process?).and_return(false) }

      it "returns the success exit code" do
        expect(processor.call).to eq(success_code)
      end
    end
  end

  context "low branch coverage" do
    before { allow(SimpleCov).to receive(:minimum_branch_coverage).and_return(95) }
    before { allow(result).to receive(:covered_branches_percent).and_return(90) }

    it "reports low branch coverage" do
      stderr = capture_stderr { expect(processor.call).to eq(min_coverage_code) }

      expect(stderr.chomp).to eq(
        "Branch coverage (90.00%) is below the expected minimum coverage (95.00%)."
      )
    end
  end

  context "low method coverage" do
    before { allow(SimpleCov).to receive(:minimum_method_coverage).and_return(95) }
    before { allow(result).to receive(:covered_methods_percent).and_return(90) }

    it "reports low method coverage" do
      stderr = capture_stderr { expect(processor.call).to eq(min_coverage_code) }

      expect(stderr.chomp).to eq(
        "Method coverage (90.00%) is below the expected minimum coverage (95.00%)."
      )
    end
  end

  context "low min file coverage" do
    before { allow(SimpleCov).to receive(:minimum_coverage_by_file).and_return(95) }
    before { allow(result).to receive(:covered_percentages).and_return([90]) }
    before { allow(result).to receive(:least_covered_file).and_return("file.rb") }

    it "reports low method coverage" do
      stderr = capture_stderr { expect(processor.call).to eq(min_coverage_code) }

      expect(stderr.chomp).to eq(
        "File (file.rb) is only (90.00%) covered. " \
        "This is below the expected minimum coverage per file of (95.00%)."
      )
    end
  end

  context "coverage dropped since last run" do
    before { allow(SimpleCov).to receive(:maximum_coverage_drop).and_return(5) }
    before { allow(result).to receive(:covered_percent).and_return(90) }
    before { allow(SimpleCov::LastRun).to receive(:read).and_return(last_run) }

    let(:last_run) do
      {"result" => {"covered_percent" => 99}}
    end

    it "reports low method coverage" do
      stderr = capture_stderr { expect(processor.call).to eq(coverage_drop_code) }

      expect(stderr.chomp).to eq(
        "Coverage has dropped by 9.00% since the last time (maximum allowed: 5.00%)."
      )
    end
  end
end
