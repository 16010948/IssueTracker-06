import React from 'react';
import { text, boolean } from '@storybook/addon-knobs';

import { TagIcon } from '@/components/atoms/icons';
import IconText from '@components/molecules/TextWithIcon';
import BoldText from '@components/atoms/BoldText';
import Button from './index';

export default {
  title: 'Atoms/Button',
  component: Button,
};

export const Default = () => {
  const content = text('text', 'default');
  const disabled = boolean('disable', false);

  return (
    <Button disabled={disabled}>
      <IconText icon={TagIcon} text={content} />
    </Button>
  );
};

export const Error = () => {
  const content = text('text', 'default');
  const disabled = boolean('disable', false);

  return (
    <Button type="error" disabled={disabled}>
      <BoldText value={content} />
    </Button>
  );
};

export const Primary = () => {
  const content = text('text', 'default');
  const disabled = boolean('disable', false);

  return (
    <Button type="primary" disabled={disabled}>
      <IconText icon={TagIcon} text={content} />
    </Button>
  );
};

export const transparent = () => {
  const content = text('text', 'default');
  const disabled = boolean('disable', false);

  return (
    <Button type="transparent" disabled={disabled}>
      <IconText icon={TagIcon} text={content} />
    </Button>
  );
};
