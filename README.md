### Bike Service – bikes Table Schema

| Field                      | Type    | Description                                       |
| -------------------------- | ------- | ------------------------------------------------- |
| bike_id                    | UUID    | Primary Key – unique identifier for the bike      |
| added_by_id                | UUID    | ID of the admin or system user who added the bike |
| is_active                  | BOOLEAN | Indicates if the bike is currently active or not  |
| is_flagged_for_maintenance | BOOLEAN | True if the bike needs maintenance                |
| model_name                 | VARCHAR | Name of the bike model                            |
| brand                      | VARCHAR | Manufacturer or brand name                        |
| max_speed_kmh              | INTEGER | Maximum speed in km/h                             |
| range_km                   | INTEGER | Range of the bike on full charge in kilometers    |
| weight_kg                  | INTEGER | Weight of the bike in kilograms                   |
| image_url                  | TEXT    | URL of the bike image (public asset or CDN link)  |
| description                | TEXT    | Optional description or notes about the bike      |
