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
  console.log('url', `${process.env.NEXT_PUBLIC_BASE_PATH ?? ''}/api/app-groups/${sp.get('id')}/`)
  fetch(`${process.env.NEXT_PUBLIC_BASE_PATH ?? ''}/api/app-groups/${sp.get('id')}/`).then(x => x.json()).then(x => console.log(x))

  return (
    <main>
      <div className={styles.container}>
        <Card elevated>
          <Text bold size="xxl">Application Group Details</Text>
          <Stack spacing="extraLoose">
            <Stack vertical>
              <Text bold>Application Group Name</Text>
              <Text bold>Log Retention Days</Text>
              <Text bold>App Group Secret</Text>
            </Stack>

            <div className={styles.textfield}>
              <Stack vertical>
                  <Textfield stretch placeholder="First Name"
                    addOnEnd={
                      <Button icon nude compact system>
                        <Edit />
                      </Button>
                    }
                  />
                <Textfield type="number" stretch placeholder="7"
                  addOnEnd={
                    <Button icon nude compact system>
                      <Edit />
                    </Button>
                  }
                />
                <Password stretch defaultValue="example"/>

              </Stack>
            </div>
          </Stack>
        </Card>
      </div>
    </main>
  )
}
