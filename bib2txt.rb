# -*- coding: utf-8 -*-

require 'bibtex'
require 'citeproc'
require 'csl/styles'

def bibentry2str(cp, b)
	return BibTeX::Value.new(cp.render :bibliography, id: b.key).to_s(:filter => :latex)
end

begin
	if ARGV.length != 2
		puts "\nUsage: %s input.bib csl_name\n\n  Example: %s sample.bib ieee  ->  format sample.bib in ieee.csl style.\n           The corresponding CSL file should be install in the system (e.g. /path/to/gems/csl-styles-?.?.?/vendor/styles/) or in the current directory (to customize the style).\n\n" % [ $0, $0 ]
		exit
	end

	unless File.exist?(ARGV[0])
		puts "[ERROR] cannot open: %s\n" % [ ARGV[0] ]
		exit
	end

	bib = BibTeX.open(ARGV[0])
	bib.replace_strings
	bib.join_strings

	cp = CiteProc::Processor.new style: ARGV[1], format: 'text'

	# 名前を省略しない
	# name = cp.engine.style.macros['author'] > 'names' > 'name'
	# name[:initialize] = 'false'

	cp.import bib.to_citeproc

	puts '# @article'
	bib['@article'].each { |b| puts bibentry2str(cp, b) }

	puts '# @inproceedings'
	bib['@inproceedings'].each { |b| puts bibentry2str(cp, b) }

	puts '# @techreport'
	bib['@techreport'].each { |b| puts bibentry2str(cp, b) }

rescue => ex
	puts ex.message
	puts $@
end
