'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import { Button } from "@asphalt-react/button";
import { Card } from "@asphalt-react/card";
import { Edit, EyeOff } from "@asphalt-react/iconpack";
import { Stack } from "@asphalt-react/stack";
import { Numeric, Password, Textfield } from "@asphalt-react/textfield";
import { Text } from "@asphalt-react/typography";
import styles from './page.module.scss';

export default function Page() {
  const sp = useSearchParams()
  const router = useRouter()

  if (sp.get("id") === null) {
    router.push('/')
  }

  return (
    <main>
      <div className={styles.container}>
        <Card elevated>
          <Text bold size="xxl">Application Group Details</Text>
          <div className={styles.stack}>
            <Stack distribution="fill" spacing="extraTight">
              <Stack vertical>
                <Text bold>Application Group Name</Text>
                <Text bold>Log Retention Days</Text>
                <Text bold>App Group Secret</Text>
              </Stack>
              <Stack vertical>
                <Textfield stretch placeholder="First Name"
                  addOnEnd={
                    <Button icon nude compact system>
                      <Edit />
                    </Button>
                  }
                />
                <Numeric stretch placeholder="7"
                  addOnEnd={
                    <Button icon nude compact system>
                      <Edit />
                    </Button>
                  }
                />
                <Password stretch defaultValue="example"/>

              </Stack>
            </Stack>
          </div>
          { sp.get('id') }
        </Card>
      </div>
    </main>
  )
}
