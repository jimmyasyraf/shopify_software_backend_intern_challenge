require 'json'
require 'httparty'

def get_all_nodes(challenge)
  first_endpoint_url = "https://backend-challenge-summer-2018.herokuapp.com/challenges.json?id=#{challenge}&page=1"
  response = HTTParty.get(first_endpoint_url)
  total_page = response["pagination"]["total"]

  total_page.times do |i|
    every_page_endpoint_url = "https://backend-challenge-summer-2018.herokuapp.com/challenges.json?id=#{challenge}&page=#{i+1}"
    response = HTTParty.get(every_page_endpoint_url)
    nodes = response["menus"]

    nodes.each do |node|
      $nodes << node
    end
  end
end

def analyze_each_node
  $nodes.each do |node|
    $root_node_id = node["id"]
    $child_node_ids = []
    #print "\nNode: #{$root_node_id}"
    cycle(node)
    #print "\nChild: #{$child_node_ids}"
    sort_by_validity($root_node_id, $child_node_ids)
  end
  $result = {"valid_menus": $valid_menus, "invalid_menus": $invalid_menus}
  $result = $result.to_json
end

def cycle(node)
  child_node_ids = node["child_ids"]
  if !child_node_ids.empty?
    unless child_node_ids.include? $root_node_id
      child_node_ids.each do |child_node_id|
        $child_node_ids << child_node_id
        child_node = $nodes.find { |e| e['id'] == child_node_id}
        cycle(child_node)
      end
    else
      child_node_ids.each do |child_node_id|
        $child_node_ids << child_node_id
      end
    end
  end
end

def sort_by_validity(root_node_id, child_node_ids)
  menu = {"root_id": root_node_id, "children": child_node_ids}
  if child_node_ids.include? root_node_id
    #print "\ninvalid\n"
    $invalid_menus << menu
  else
    #print "\nvalid\n"
    $valid_menus << menu
  end
end

def get_output(challenge)
  $nodes = []
  $valid_menus = []
  $invalid_menus = []
  $result = {}
  get_all_nodes(challenge)
  analyze_each_node()
  File.open("output#{challenge}.json","w") do |f|
    f.write($result)
  end
end

get_output(1)

get_output(2)
