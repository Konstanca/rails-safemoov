module ApplicationHelper
end

def format_count(number)
  if number >= 1000
    "#{(number / 1000.0).round(1)}k"
  else
    number.to_s
  end
end
