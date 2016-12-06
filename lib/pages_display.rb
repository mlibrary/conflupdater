class PagesDisplay
  attr :raw_pages

  # @param [Hash] pages from JSON confluence API result
  def initialize(pages)
    @raw_pages = pages
  end

  def sort_refined_pages(pages)
    pages.sort{|lhs, rhs| lhs[:ancestor_ids] <=> rhs[:ancestor_ids]}
  end

  def refine_page_info(page)
    ancestor_ids = page['ancestors'].map{|ancestor| ancestor['id']}
    {id: page['id'], title: page['title'], ancestor_ids: ancestor_ids}
  end

  def to_s
    refined_pages = @raw_pages.map{|p| refine_page_info p}
    sorted = sort_refined_pages(refined_pages)
    str = "Pages:"
    res = sorted.map{|p| "  "*p[:ancestor_ids].count + "(#{p[:id]}) #{p[:title]}\n"}
                .reduce(:+)
  end
end
