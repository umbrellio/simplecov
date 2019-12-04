# frozen_string_literal: true

require "helper"

describe SimpleCov::SourceFile do
  let(:coverage_for_never_rb) do
    {:lines => [nil, nil]}
  end

  # TODO: add methods
  let(:sample_coverage) do
    {
      :lines => [nil, 1, 1, 1, nil, nil, 1, 0, nil, nil, nil, nil, nil, nil, nil, nil],
      :branches => {
        [:if, 0, 2, 6, 6, 9] => {
          [:then, 1, 3, 8, 4, 81] => 3,
          [:else, 2, 5, 8, 6, 19] => 0,
        },
        [:if, 3, 9, 6, 15, 9] => {
          [:then, 4, 9, 8, 10, 81] => 3,
          [:else, 5, 11, 8, 14, 20] => 0,
        },
      },
    }
  end

  context "a source file initialized with some coverage data" do
    subject do
      SimpleCov::SourceFile.new(source_fixture("sample.rb"), sample_coverage)
    end

    it "has a filename" do
      expect(subject.filename).not_to be_nil
    end

    it "has source equal to src" do
      expect(subject.src).to eq(subject.source)
    end

    it "has a project filename which removes the project directory" do
      expect(subject.project_filename).to eq("/spec/fixtures/sample.rb")
    end

    context "when project_root contains special characters" do
      let(:root) { File.expand_path("foo[]bar") }

      around do |example|
        old_root = SimpleCov.root
        SimpleCov.root(root)
        begin
          example.run
        ensure
          SimpleCov.root(old_root)
        end
      end

      it "works" do
        source_file = SimpleCov::SourceFile.new(File.expand_path("sample.rb", root), sample_coverage)
        expect(source_file.project_filename).to eq("/sample.rb")
      end
    end

    it "has source_lines equal to lines" do
      expect(subject.lines).to eq(subject.source_lines)
    end

    it "has 16 source lines" do
      expect(subject.lines.count).to eq(16)
    end

    it "has all source lines of type SimpleCov::SourceFile::Line" do
      subject.lines.each do |line|
        expect(line).to be_a SimpleCov::SourceFile::Line
      end
    end

    it "has 'class Foo' as line(2).source" do
      expect(subject.line(2).source).to eq("class Foo\n")
    end

    it "has 80% covered_percent" do
      expect(subject.covered_percent).to eq(80.0)
    end

    it "Has all branches count 4" do
      expect(subject.all_branches.size).to eq(4)
    end

    it "Has relevant branches count 3" do
      expect(subject.relevant_branches.size).to eq(3)
    end

    it "Has covered branches count 2" do
      expect(subject.covered_branches.size).to eq(2)
    end

    it "Has missed branches count 1" do
      expect(subject.missed_branches.size).to eq(1)
    end

    it "Has root branches count 2" do
      expect(subject.root_branches.size).to eq(2)
    end

    it "Has branch on line number 8" do
      expect(subject.branch_per_line(8)).to eq('[3, "+"]')
    end

    it "Has no branch on line number 9" do
      expect(subject.branch_per_line(9)).to eq("")
    end

    it "Has coverage report" do
      expect(subject.branches_report).to eq(
        2 => [[3, "+"]],
        4 => [[0, "-"]],
        8 => [[3, "+"]],
        10 => [[0, "-"]]
      )
    end

    it "Hash line 10 with missed branches" do
      expect(subject.line_with_missed_branch?(10)).to eq(true)
    end

    it "returns lines number 2, 3, 4, 7 for covered_lines" do
      expect(subject.covered_lines.map(&:line)).to eq([2, 3, 4, 7])
    end

    it "returns lines number 8 for missed_lines" do
      expect(subject.missed_lines.map(&:line)).to eq([8])
    end

    it "returns lines number 1, 5, 6, 9, 10, 16 for never_lines" do
      expect(subject.never_lines.map(&:line)).to eq([1, 5, 6, 9, 10, 16])
    end

    it "returns line numbers 11, 12, 13, 14, 15 for skipped_lines" do
      expect(subject.skipped_lines.map(&:line)).to eq([11, 12, 13, 14, 15])
    end

    it "has 80% covered_percent" do
      expect(subject.covered_percent).to eq(80.0)
    end
  end

  context "A file that have inline branches" do
    let(:coverage_for_dumb_inline) do
      {
        :lines => [nil, 1, 1, 1, nil, nil, 1, 0, nil, nil, nil, nil, nil, nil, nil, nil],
        :branches => {
          [:if, 0, 3, 6, 3, 9] => {
            [:then, 1, 3, 8, 3, 81] => 3,
            [:else, 2, 3, 8, 4, 19] => 0,
          },
          [:if, 3, 9, 6, 15, 9] => {
            [:then, 4, 10, 8, 10, 81] => 3,
            [:else, 5, 11, 8, 14, 20] => 0,
          },
        },
      }
    end

    subject do
      SimpleCov::SourceFile.new(source_fixture("sample.rb"), coverage_for_dumb_inline)
    end

    it "Has branches report on 3 lines" do
      expect(subject.branches_report.keys.size).to eq(3)
      expect(subject.branches_report.keys).to eq([3, 9, 10])
    end

    it "Has all branches count 4" do
      expect(subject.all_branches.size).to eq(4)
    end

    it "Has relevant branches count 3" do
      expect(subject.relevant_branches.size).to eq(3)
    end

    it "Has covered branches count 2" do
      expect(subject.covered_branches.size).to eq(2)
    end

    it "Has dual element in condition at line 18 report" do
      expect(subject.branches_report[3]).to eq([[3, "+"], [0, "-"]])
    end

    it "Has branches coverage percent 2/3" do
      expect(subject.branches_coverage_percent.round(2)).to eq(66.67)
    end
  end

  context "a file that is never relevant" do
    let(:coverage) do
      {:lines => [nil, 1, 1, 1, nil, nil, 1, 0, nil, nil, nil, nil, nil, nil, nil, nil, nil]}
    end

    subject do
      SimpleCov::SourceFile.new(source_fixture("sample.rb"), coverage)
    end

    it "has 16 source lines regardless of extra data in coverage array" do
      # Do not litter test output with known warning
      capture_stderr { expect(subject.lines.count).to eq(16) }
    end

    it "prints a warning to stderr if coverage array contains more data than lines in the file" do
      captured_output = capture_stderr do
        subject.lines
      end

      expect(captured_output).to match(/^Warning: coverage data provided/)
    end
  end

  context "a file that is never relevant" do
    subject do
      SimpleCov::SourceFile.new(source_fixture("never.rb"), coverage_for_never_rb)
    end

    context "a file where nothing is ever executed mixed with skipping #563" do
      it "has 0.0 covered_strength" do
        expect(subject.covered_strength).to eq 0.0
      end
    end
  end

  context "a file where nothing is ever executed mixed with skipping #563" do
    let(:coverage) do
      {:lines => [nil, nil, nil, nil]}
    end

    subject do
      SimpleCov::SourceFile.new(source_fixture("skipped.rb"), coverage)
    end

    it "has 0.0 covered_strength" do
      expect(subject.covered_strength).to eq 0.0
    end

    it "has 0.0 covered_percent" do
      expect(subject.covered_percent).to eq 0.0
    end
  end

  context "a file where everything is skipped and missed #563" do
    let(:coverage) do
      {:lines => [nil, nil, 0, nil]}
    end

    subject do
      SimpleCov::SourceFile.new(source_fixture("skipped.rb"), coverage)
    end

    it "has 0.0 covered_strength" do
      expect(subject.covered_strength).to eq 0.0
    end

    it "has 0.0 covered_percent" do
      expect(subject.covered_percent).to eq 0.0
    end
  end

  context "a file where everything is skipped/irrelevamt but executed #563" do
    let(:coverage) do
      {:lines => [nil, nil, 1, 1, 0, nil, nil, nil]}
    end

    subject do
      SimpleCov::SourceFile.new(source_fixture("skipped_and_executed.rb"), coverage)
    end

    it "has 0.0 covered_strength" do
      expect(subject.covered_strength).to eq 0.0
    end

    it "has 0.0 covered_percent" do
      expect(subject.covered_percent).to eq 0.0
    end
  end
end
