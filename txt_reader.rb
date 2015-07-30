# -*- encoding : utf-8 -*-
require 'rubygems'
# require 'matrix'

require_relative 'depenses'
require_relative 'file_reader'

class TxtReader < FileReader

  def initialize(filename, config)
    @filename = filename
    parse
  end

  protected

  def parse
    @participants = nil
    f = File.open(filename, "r")

    # Scan for participants
    while true
      line = f.gets
      if line.nil?
        # end of reached without finding participants ?
        raise 'participants list not found in file'
        break
      end
      if line.match(/^Participants:\s*([\w-]+(\s*,\s*[\w-]+)*)/)
        @participants = $1.scan(/[\w-]+/)
        break
      end
    end

    # Scan for expenses
    @depenses = Depenses.new(@participants)
    while line = f.gets
      next if line[0] == '#' or line.strip.empty?  # Ignore commented lines
      if line.match(/^\s*[-*]\s*([\w-]+)\s+(\d+([\.,]\d+)?)\s+([^\[\]]+)\s+(\[([\w-]+)(\s*,\s*[\w-]+)*\])?/)
        # Match something like  "- Chris 4.5 tickets for boat [Bruno, Chris]"
        payer = $1
        amount = to_f($2)
        why = $4
        concerned_persons = $5 ? $5.scan(/[\w-]+/) : :tous
        @depenses.ajouter_depense(payer, amount, concerned_persons, why)
      else
        raise "Unparsed line: #{line}"
      end
    end
  end

  def to_f(str)
    return str.tr(',','.').to_f
  end

end
