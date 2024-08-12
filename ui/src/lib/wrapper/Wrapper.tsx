'use client';

import { AppbarHead, AppbarBody, AppbarTail, BaseAppbar } from '@asphalt-react/appbar';
import styles from './wrapper.module.scss';

export default function Wrapper({
	children,
}: Readonly<{
	children: React.ReactNode;
}>) {
	return <>
		<BaseAppbar>
		  <AppbarHead>
		    <a href="/" style={{color: styles.primaryColor}}>Barito Log</a>
		  </AppbarHead>
		  <AppbarBody>
		    body
		  </AppbarBody>
		  <AppbarTail>
		    <div>Username</div>
		    <div>Sign Out</div>
		  </AppbarTail>
		</BaseAppbar>
		{children}
	</>
}
