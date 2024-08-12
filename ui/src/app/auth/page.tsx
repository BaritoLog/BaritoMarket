'use client';
import { AppbarHead, AppbarBody, AppbarTail, BaseAppbar } from '@asphalt-react/appbar';
import { Button } from '@asphalt-react/button';
import variables from './page.module.scss';

export default function Page() {
  return <main>
    <BaseAppbar>
      <AppbarHead>
        <a href="/">Barito Log</a>
      </AppbarHead>
      <AppbarBody>
        body
      </AppbarBody>
      <AppbarTail>
        <div>Username</div>
        <div>Sign Out</div>
      </AppbarTail>
    </BaseAppbar>
  </main>
  return <div>
    <Button nude>asdasd</Button>
    <h1 style={{ color: variables.primaryColor }}>helo</h1>
  </div>
  }
