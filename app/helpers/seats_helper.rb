module SeatsHelper
  def star_rating
    r = rand(1..5)
    "★" * r + "☆" * (5 - r)
  end
end
