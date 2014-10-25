# -*- encoding : utf-8 -*-
require 'rubygems'
require 'zip'          # gem rubyzip
require 'xml/libxml'   # gem libxml
require 'matrix'

require_relative 'depenses'

class OoReader

  attr_accessor :filename
  attr_accessor :contenu_xml
  attr_accessor :participants
  attr_accessor :nb_tableaux_parse  # Nombre de sous tableaux trouvés

  attr_accessor :depenses

  # config : {
  #   'texte_participants' => 'Participants :',
  #   'column_numbers' => {'prenom' => 2, 'pour_qui' => 5, 'montant' => 3, 'pourquoi' => 4},
  #   :premiere_ligne_tableau => 4
  # }
  def initialize(filename, config)
    @filename = filename
    @config = config
    zip = Zip::File.open(filename)
    @contenu_xml = zip.read('content.xml')
    @nb_tableaux_parse = 0
    parse
  end

  def afficher_depenses
    puts depenses
  end

  protected

  def parse
    xml_reader = XML::Parser.string(@contenu_xml).parse
    scanner_participants(xml_reader)
    @depenses = Depenses.new(@participants)
    noeud = xml_reader.find("//table:table[@table:name='Sheet1']/table:table-row[1]").first

    while noeud and noeud = trouver_prochain_tableau(noeud)
      noeud = scanner_tableau(noeud)
      @nb_tableaux_parse += 1
    end

    raise "Aucun tableau trouvé !" if @nb_tableaux_parse == 0
  end

  # renvoie le noeud contenant le prochain tableau répondant au format
  def trouver_prochain_tableau(noeud)
    # regarde si ce table-row correspond à une ligne interprétable
    def est_une_ligne_tableau(noeud)
      def get_colone(noeud, n)
        non_nul(n);
        non_nul(noeud)
        resultat = noeud.find("table:table-cell[#{n}]")
        return resultat.first ? resultat.first.content : nil
      end
      return false unless res = get_colone(noeud, @config['column_numbers']['montant']) and res.to_f != 0
      return false unless res = get_colone(noeud, @config['column_numbers']['prenom']) and @participants - res.scan(/[\w-]+/) != @participants
      return true
    end

    noeud = noeud.next
    while noeud and ! est_une_ligne_tableau(noeud)
      noeud = noeud.next
    end
    return noeud
  end

  def ajouter_depense(prenom, montant, personnes_concernees, pourquoi = nil)
    require 'pp'
    if personnes_concernees.size == 0
      personnes_concernees = :tous
    else
      personnes_concernees = personnes_concernees.scan(/[\w-]+/)
    end
    @depenses.ajouter_depense(prenom, montant, personnes_concernees, pourquoi)
  end

  def scanner_tableau(noeud_depenses)
    while true do
      prenom = noeud_depenses.find("table:table-cell[#{@config['column_numbers']['prenom']}]").first.content
      personnes_concernees = noeud_depenses.find("table:table-cell[#{@config['column_numbers']['pour_qui']}]").first.content
      montant = noeud_depenses.find("table:table-cell[#{@config['column_numbers']['montant']}]").first.content
      pourquoi = noeud_depenses.find("table:table-cell[#{@config['column_numbers']['pourquoi']}]").first.content
      montant = to_f(montant)
      ajouter_depense(prenom, montant, personnes_concernees, pourquoi)
      noeud_depenses = noeud_depenses.next
      break if noeud_depenses.find('table:table-cell/text:p').size == 0
    end
    return noeud_depenses
  end

  # remplis @participants
  def scanner_participants(xml)
    noeud_participants = nil
    xml.find('//text:p').each do |noeud|
      noeud_participants = noeud if noeud.content.strip == @config['texte_participants']
    end
    raise "Liste des participants non trouvée (recherche du texte '#{@config['texte_participants']}')" unless noeud_participants

    @participants = noeud_participants.parent.parent.find('.//text:p')[1].content.scan(/[\w-]+/)
    non_nul(@participants)
  end

  def non_nuls(tableau_objets)
    tableau_objets.each do |objet|
      non_nul(objet)
    end
  end

  def non_nul(objet)
    raise "ooops, un nil" if objet.nil?
  end

  def to_s
    s = '-- OoReader'
    [:filename, :participants, :depenses_communes, :dettes_persos].each do |attr|
      s << "- @#{attr.to_s} = \n"
      s << (eval "@#{attr.to_s}") + "\n"
    end
    return s
  end

  def to_f(str)
    return str.tr(',','.').to_f
  end

end
