import React from "react";
import { TextInput, FormDataConsumer, BooleanInput } from "react-admin";
import { Grid } from "@mui/material";
import { isEmpty } from "lodash";

const CreateServerText = ({ source }) => {
  return (
    <FormDataConsumer>
      {({ formData, ...rest }) => (
        <Grid item xs={12}>
          <TextInput
            multiline
            source={source}
            label="Generated Nginx Server Config"
            helperText="For example: server {listen       8000; listen       somename:8080; server_name  somename  alias  another.alias; location / { root   html; index  index.html index.htm; }}"
            fullWidth
            format={() => `server {
            ${formData?.listens?.length
                ? formData?.listens
                  .map((listen) => {
                    return `listen ${listen.listen || ""};`;
                  })
                  .join("\n")
                : ""
              }  # Listen on port (HTTP)
            server_name ${formData.server_name || "example.com"
              };  # Your domain name
            root ${formData.root || "/var/www/html"};  # Document root directory
            index ${formData.index || "index.html index.htm"
              };  # Default index files
            access_log ${formData.access_log || "/var/log/nginx/access.log"
              };  # Access log file location
            error_log ${formData.error_log || "/var/log/nginx/error.log"
              };  # Error log file location

            ${formData?.locations?.length
                ? formData.locations
                  .map((location) => {
                    return `location ${location?.location_path || "/"} {
                      ${location?.location_vals
                        ? Object.values(location?.location_opts)
                          .map((idx) => {
                            const value = location?.location_vals[idx];
                            return idx + " " + value;
                          })
                          .join("\n")
                        : "#Please select an Options"
                      }
                        ${!isEmpty(formData?.custom_location_block)
                          ? formData?.custom_location_block
                          .map((block) => block.additional_location_block)
                          .join("\n")
                          : ""
                        }
                      }`;
                  })
                  .join("\n")
                : ""
              }
              ${!isEmpty(formData?.custom_block)
                ? formData?.custom_block
                  .map((block) => block.additional_block)
                  .join("\n")
                : ""
              }
            }
            ${!isEmpty(formData?.custom_http_block)
              ? formData?.custom_http_block
              .map((block) => block.additional_http_block)
              .join("\n")
              : ""
            }
          `}
          />
          <BooleanInput
            source="config_status"
            label="Active"
            fullWidth
            defaultValue={false}
          />
        </Grid>
      )}
    </FormDataConsumer>
  );
};

export default CreateServerText;
