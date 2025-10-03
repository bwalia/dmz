import React from 'react';
import Form from './Form';
import { Create as RaCreate } from 'react-admin';
const Create = () => {
  return (
    <RaCreate title={"Server"} redirect="list">
        <Form type="create" />
    </RaCreate>
  )
}

export default Create