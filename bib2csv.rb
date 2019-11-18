# -*- coding: utf-8 -*-

require 'bibtex'
require 'citeproc'
require 'csl/styles'
require 'date'

HJ='"タイトル(日本語)","タイトル(英語)","著者(日本語)","著者(英語)","誌名(日本語)","誌名(英語)","巻","号","開始ページ","終了ページ","出版年月","査読の有無","招待の有無","記述言語","掲載種別","ISSN","ID:DOI","ID:JGlobalID","ID:NAID(CiNiiのID)","ID:PMID","Permalink","URL","概要(日本語)","概要(英語)"'
HE='"Title(English)","Title(Japanese)","Author(English)","Author(Japanese)","Journal(English)","Journal(Japanese)","Volume","Number","Starting page","Ending page","Publication date","Refereed paper","Invited paper","Language","Publishing type","ISSN","ID:DOI","ID:JGlobalID","ID:NAID","ID:PMID","Permalink","URL","Description(English)","Description(Japanese)"'

class BibTeX::Entry
	attr_accessor :x_authors
	attr_accessor :x_title
	attr_accessor :x_locators
	attr_accessor :x_date
	attr_accessor :x_ps
	attr_accessor :x_pe
	attr_accessor :x_lang
	attr_accessor :x_reviewed
	attr_accessor :x_invited
	attr_accessor :x_doi

	def to_s()
		return sprintf('"%s","","%s","","%s","","%s","%s","%s","%s","%s","%s","%s","%s","","","%s","","","","","","",""',
			self.x_title, self.x_authors, self.x_locators, self['volume'], self['number'], self.x_ps, self.x_pe, self.date, self.x_reviewed, self['invited'], self.x_lang, self.x_doi)
	end

    def is_ja(txt)
        return txt =~ /(?:\p{Hiragana}|\p{Katakana}|[一-龠々])/ ? true : false
    end

	def update(cp)
		x = cp.render :bibliography, id: self.key
		x = x[0].split("\t")
		self.x_authors = BibTeX::Value.new(x[0]).to_s(:filter => :latex)
		self.x_title = BibTeX::Value.new(x[1]).to_s(:filter => :latex)
		self.x_locators = BibTeX::Value.new(x[2]).to_s(:filter => :latex)

		case self['language']
		when "japanese", "ja" then
			self.x_lang = "ja"
		when "english", "en" then
			self.x_lang = "en"
		else
			#self.x_lang = x[0] =~ /^[ -~]*$/ && self.x_locators =~ /^[ -~]*$/ ? "en" : "ja"
			self.x_lang = is_ja(x_authors) || is_ja(x_locators) ? "ja" : "en"
		end

		case self['reviewed']
		when "1" then
			self.x_reviewed = 1
		when "0" then
			self.x_reviewed = 0
		else
			case self.type.to_s
			when "article", "proceedings" then
				self.x_reviewed = 1
			else
				self.x_reviewed = 0
			end
		end

		case self['invited']
		when "1" then
			self.x_invited = 1
		else
			self.x_invited = 0
		end

		if self.pages !~ /^[0-9]+-*[0-9]+$/
			self.x_ps = ""
			self.x_pe = ""
		else
			self.x_ps, self.x_pe = /([0-9]+)-*([0-9]+)/.match(self.pages).captures
		end

		if !self.month_numeric.nil?
			self.date = sprintf("%04d%02d00", Date.strptime(self.year, "%Y").strftime("%Y"), self.month_numeric)
		else
			self.date = sprintf("%04d0000", Date.strptime(self.year, "%Y").strftime("%Y"))
		end

        if !self['doi'].nil?
            self.x_doi = self['doi']
        elsif !self['pdf'].nil? && m = self['pdf'].match(/^https?:\/\/(?:dx.)?doi.org\/(.+)/)
            self.x_doi = m[1]
        elsif !self['url'].nil? && m = self['url'].match(/^https?:\/\/(?:dx.)?doi.org\/(.+)/)
            self.x_doi = m[1]
        end
	end
end

begin
	if ARGV.length != 1
		puts "\nUsage: %s input.bib\n\n\tInput: input.bib\n\tOutput: paper_e.csv, paper_j.csv, misc_e.csv, misc_j.csv\n\n" % [ $0 ]
		exit
	end

	unless File.exist?(ARGV[0])
		puts "[ERROR] cannot open: %s\n" % [ ARGV[0] ]
		exit
	end

	bib = BibTeX.open(ARGV[0])
	bib.replace_strings
	bib.join_strings

	cp = CiteProc::Processor.new style: 'bib2csv', format: 'text'
	cp.import bib.to_citeproc

	bib['@*'].each do |b|
		b.update(cp)
	end

	paper_e, paper_j = bib['@article,@inproceedings'].partition{ |b| b.x_lang == "en" }
	File.open('paper_e.csv', 'w:UTF-8') { |f| f.puts HE; f.puts paper_e }
	File.open('paper_j.csv', 'w:UTF-8') { |f| f.puts HJ; f.puts paper_j }

	misc_e, misc_j = bib['@techreport'].partition{ |b| b.x_lang == "en" }
	File.open('misc_e.csv', 'w:UTF-8') { |f| f.puts HE; f.puts misc_e }
	File.open('misc_j.csv', 'w:UTF-8') { |f| f.puts HJ; f.puts misc_j }

rescue => ex
	puts ex.message
	puts $@
end
