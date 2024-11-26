json.extract! paper, :id, :url, :title, :read, :authors, :year, :auto_summary, :notes, :created_at, :updated_at
json.url paper_url(paper, format: :json)
