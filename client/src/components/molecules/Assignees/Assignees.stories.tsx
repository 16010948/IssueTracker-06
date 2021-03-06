import React from 'react';
import Assignees from './Assignees';

export default {
  title: 'Molecules/Assignees',
  component: Assignees,
};

const DUMMY_PROFILE =
  'https://avatars0.githubusercontent.com/u/37282087?s=40&amp;v=4';

export const Default = () => {
  const users = [
    { id: 0, name: 'user1', profile: DUMMY_PROFILE, email: '' },
    { id: 1, name: 'user2', profile: DUMMY_PROFILE, email: '' },
    { id: 2, name: 'user3', profile: DUMMY_PROFILE, email: '' },
  ];
  return <Assignees users={users} />;
};
