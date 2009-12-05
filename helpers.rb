def create_sap_records(items, project_map)
    result = {}
    for item in items:
        update_or_create_sap_record result, item, project_map
    end

    p result
    return result.values
end


def format_hh_mm(minutes)
    # TODO: nach sprintf oder sowas in ruby suchen
    hours = minutes / 60
    rest_minutes = minutes % 60
    if rest_minutes < 10
        "#{hours}:0#{rest_minutes}"
    else
        "#{hours}:#{rest_minutes}"
    end
end

def format_hh_min_as_decimal(minutes)
    hours = (100 * minutes / 60.0)
    value = (hours.round() / 100.0).to_s
    value.sub(/[.]/, ",")
end
