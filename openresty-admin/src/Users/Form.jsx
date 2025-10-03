import { Grid } from "@mui/material";
import React from "react";
import { NumberInput, SelectInput, SimpleForm, TextInput } from "react-admin";

const Form = () => {
  return (
    <SimpleForm>
      <Grid container spacing={2}>
        <Grid item xs={6}>
          <TextInput source="name" label="Full Name" fullWidth />
        </Grid>
        <Grid item xs={6}>
          <TextInput source="email" label="Email" fullWidth type="email" />
        </Grid>
        <Grid item xs={6}>
          <TextInput source="phone" label="Phone Number" fullWidth />
        </Grid>
        <Grid item xs={6}>
          <TextInput source="website" label="Website" fullWidth />
        </Grid>
        <Grid item xs={6}>
          <TextInput source="company.name" label="Compnay name" fullWidth />
        </Grid>
        <Grid item xs={6}>
          <TextInput source="company.bs" label="Compnay BS" fullWidth />
        </Grid>
        <Grid item xs={6}>
          <TextInput source="address.city" fullWidth />
        </Grid>
        <Grid item xs={6}>
          <TextInput source="address.suite" fullWidth />
        </Grid>
        <Grid item xs={6}>
          <TextInput source="address.street" fullWidth />
        </Grid>
        <Grid item xs={6}>
          <TextInput source="address.zipcode" fullWidth />
        </Grid>
        <Grid item xs={6}>
          <TextInput source="password" type="password" fullWidth />
        </Grid>
        <Grid item xs={6}>
          <SelectInput source="user_role" sx={{ marginTop: "0", marginBottom: "0"}} fullWidth choices={[
            {id: '98aolp-asd32-sdfczsd-34fds', name: 'authenticated'},
            {id: '91adfp-trd32-sdkm23d-34f5s', name: 'admin'},
          ]} />
        </Grid>
      </Grid>
    </SimpleForm>
  );
};

export default Form;
