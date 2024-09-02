'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import { Button } from "@asphalt-react/button";
import { Card } from "@asphalt-react/card";
import { Edit } from "@asphalt-react/iconpack";
import { Loader } from "@asphalt-react/loader";
import { Textfield } from "@asphalt-react/textfield";
import { ToggleSwitch } from "@asphalt-react/toggle-switch";
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
    return <div className={styles.loader}><Loader/></div>
  }

  return (
    <main>
      <div className={styles.container}>
        <Card elevated>
          <Text bold size="l">Application Group Details</Text>
          <div className={styles.grid}>
              <Text bold size="s">Application Group Name</Text>
              <div>
              <Textfield
                size="s"
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
</div>

              <Text bold size="s">Log Retention Days</Text>
              <div>
              <Textfield
                type="number"
                size="s"
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
              /></div>
              <Text bold size="s">App Group Secret</Text>
              <div><ReadOnlyPassword initialValue={appGroupData.secret}/></div>
              <Text bold size="s">Cluster Name</Text>
              <Text size="s">{appGroupData.cluster_name}</Text>
              <Text bold size="s">TPS</Text>
              <div>
              <Textfield
                type="number"
                size="s"
                placeholder="TPS"
                value={appGroupData.tps}
                onChange={(e) => {
                  setAppGroupData({
                    ...appGroupData,
                    tps: e.target.value,
                  })
                }}
                addOnEnd={
                  <Button icon nude compact system>
                    <Edit />
                  </Button>
                }
              /></div>
              <Text bold size="s">Redaction Status</Text>
              <div className={styles.toggleSwitch}>
                <ToggleSwitch
                  size="s"
                  on={appGroupData.is_redaction_active}
                  onToggle={({on}) => {
                    setAppGroupData({
                      ...appGroupData,
                      is_redaction_active: on,
                    })
                  }}
                />
              </div>
              <Text bold size="s">App Group Status</Text>
              <div className={styles.toggleSwitch}>
                <ToggleSwitch
                  size="s"
                  on={appGroupData.is_active}
                  onToggle={({on}) => {
                    setAppGroupData({
                      ...appGroupData,
                      is_active: on,
                    })
                  }}
                />
              </div>
              <Text bold size="s">Total Daily Log Ingested</Text>
              <Text size="s">{appGroupData.total_daily_log_ingested}</Text>
              <Text bold size="s">Total Daily Cost</Text>
              <Text size="s">${appGroupData.total_daily_cost}</Text>
              {
                Object.entries(appGroupData.labels).map(k => (<>
                  <Text bold size="s">{k[0]}</Text>
                  <Text size="s">{k[1]}</Text>
                </>))
              }
          </div>
        </Card>
      </div>
    </main>
  )
}
