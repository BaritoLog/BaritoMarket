'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import { Button } from "@asphalt-react/button";
import { Card } from "@asphalt-react/card";
import { Edit } from "@asphalt-react/iconpack";
import { Stack } from "@asphalt-react/stack";
import { Password, Textfield } from "@asphalt-react/textfield";
import { Text } from "@asphalt-react/typography";
import styles from './page.module.scss';
import { useEffect, useState } from 'react';
import ReadOnlyPassword from '@/lib/readonly-password/ReadOnlyPassword';

export default function Page() {
  const sp = useSearchParams()
  const router = useRouter()
  const [appGroupData, setAppGroupData] = useState(null)

  useEffect(() => {
    if (sp.get("id") === null) {
      router.push('/')
      return
    }

    const fetchAppGroupData = async () => {
      try {
        const response = await fetch(`${process.env.NEXT_PUBLIC_BASE_PATH ?? ''}/api/app-groups/${sp.get('id')}/`)
        const data = await response.json()
        setAppGroupData(data)
      } catch (error) {
        console.error('Error fetching app group data:', error)
      }
    }

    fetchAppGroupData()
  }, [sp, router])

  if (!appGroupData) {
    return <div>Loading...</div>
  }

  return (
    <main>
      <div className={styles.container}>
        <Card elevated>
          <Text bold size="l">Application Group Details</Text>
          <div className={styles.grid}>
              <Text bold>Application Group Name</Text>
              <Textfield
                stretch
                placeholder="Application Group Name"
                value={appGroupData.name}
                onChange={(e) => {
                  setAppGroupData({
                    ...appGroupData,
                    name: e.target.value,
                  })
                }}
                addOnEnd={
                  <Button icon nude compact system>
                    <Edit />
                  </Button>
                }
              />
              <Text bold>Log Retention Days</Text>
              <Textfield
                type="number"
                stretch
                placeholder="Log Retention Days"
                value={appGroupData.log_retention_days}
                onChange={(e) => {
                  setAppGroupData({
                    ...appGroupData,
                    log_retention_days: e.target.value,
                  })
                }}
                addOnEnd={
                  <Button icon nude compact system>
                    <Edit />
                  </Button>
                }
              />
              <Text bold>App Group Secret</Text>
              <ReadOnlyPassword initialValue={appGroupData.secret}/>
              <Text bold>Cluster Name</Text>
              <Text bold>{appGroupData.cluster_name}</Text>
          </div>
        </Card>
      </div>
    </main>
  )
}
