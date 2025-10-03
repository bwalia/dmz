import React from 'react';
import { useStore, useDataProvider } from 'react-admin';
import {
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    Button,
    FormControl,
    InputLabel,
    Select,
    MenuItem,
} from "@mui/material";

import { isEmpty } from 'lodash';


const EnvProfileHandler = ({ open, onClose, title, content }) => {
    const [ruleProfileFilter, setRuleProfileFilter] = useStore('rules.listParams', {});
    const [serverProfileFilter, setServerProfileFilter] = useStore('servers.listParams', {});
    const [profileData, setProfileData] = React.useState({});
    const dataProvider = useDataProvider();

    const params = {
        "pagination": {
            "page": 1,
            "perPage": 1000
        },
        "sort": {
            "field": "id",
            "order": "ASC"
        },
        "filter": {}
    }
    React.useEffect(() => {
        const profileList = dataProvider.getList("profiles", params)
        profileList.then(profiles => {
            setProfileData(profiles?.data)
        })
    }, [])
    const [profile, setProfile] = React.useState('');
    const handleChange = (event) => {
        if (!isEmpty(ruleProfileFilter)) {
            const ruleFilter = { ...ruleProfileFilter };
            ruleFilter.filter.profile_id = event.target.value
            setRuleProfileFilter(ruleFilter);
            let displayedFilters = window.location.href;
            displayedFilters = displayedFilters.split("?")[0];
            window.history.pushState({}, "", displayedFilters);
        }
        if (!isEmpty(serverProfileFilter)) {
            const serverFilter = { ...serverProfileFilter };
            serverFilter.filter.profile_id = event.target.value
            setServerProfileFilter(serverFilter);
        }
        localStorage.setItem('environment', event.target.value);
        setProfile(event.target.value);
        dataProvider.profileUpdate("settings/profile", { profile: event.target.value })
    };
    return (
        <Dialog open={open} onClose={onClose}>
            <DialogTitle>{title}</DialogTitle>
            <DialogContent>
                <FormControl fullWidth>
                    <InputLabel id="demo-simple-select-label">Profile</InputLabel>
                    <Select
                        labelId="demo-simple-select-label"
                        id="demo-simple-select"
                        value={profile}
                        label="Profile"
                        onChange={handleChange}
                    >
                        {profileData.length && profileData.map((profile) => (
                            <MenuItem value={profile.id}>{profile.name}</MenuItem>
                        ))}
                    </Select>
                </FormControl>
            </DialogContent>
            <DialogActions>
                <Button onClick={onClose} color="primary">
                    Close
                </Button>
            </DialogActions>
        </Dialog>
    )
}

export default EnvProfileHandler