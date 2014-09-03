# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "lawyer"
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Wen Li"]
  s.date = "2014-02-25"
  s.description = "Archer lanucher"
  s.email = "wenli@baidu.com"
  s.files = ["lib/lawyer.rb", "lib/lawyer/base.rb"]
  s.homepage = "http://gitlab.baidu.com/"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Archer lanucher"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
