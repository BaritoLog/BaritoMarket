'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import { useEffect, useState } from 'react';
import ReadOnlyPassword from '@/lib/readonly-password/ReadOnlyPassword';
import styles from './page.module.scss';
import { Button } from "@asphalt-react/button";
import { Card } from "@asphalt-react/card";
import { Cloud, Key, SeriesSearch, Search, Tag, Tick } from "@asphalt-react/iconpack";
import { Loader } from "@asphalt-react/loader";
import { Textfield } from "@asphalt-react/textfield";
import { ToggleSwitch } from "@asphalt-react/toggle-switch";
import { Text } from "@asphalt-react/typography";
import { Stack } from "@asphalt-react/stack";

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
          <Text bold size="l">App Group Details: {appGroupData.cluster_name}</Text>
          <hr/>
          <div className={styles.grid}>
              <Text bold >Application Group Name</Text>
              <div><Textfield
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
                      <Tick />
                    </Button>
                  }
                />
              </div>

              <Text bold >Log Retention Days</Text>
              <div><Textfield
                type="number"
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
                    <Tick />
                  </Button>
                }
              /></div>
              <Text bold >App Group Secret</Text>
              <div><ReadOnlyPassword initialValue={appGroupData.secret}/></div>
              <Text bold >TPS</Text>
              <div><Textfield
                type="number"
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
                    <Tick />
                  </Button>
                }
              /></div>
              <Text bold >App Group Status</Text>
              <div className={styles.toggleSwitch}><ToggleSwitch
                  on={appGroupData.is_active}
                  onToggle={({on}) => {
                    setAppGroupData({
                      ...appGroupData,
                      is_active: on,
                    })
                  }}
                /></div>
              <Text bold >Redaction Status</Text>
              <div className={styles.toggleSwitch}><ToggleSwitch
                  on={appGroupData.is_redaction_active}
                  onToggle={({on}) => {
                    setAppGroupData({
                      ...appGroupData,
                      is_redaction_active: on,
                    })
                  }}
                /></div>
              <Text bold >Total Daily Log Ingested</Text>
              <Text >{appGroupData.total_daily_log_ingested}</Text>
              <Text bold >Total Daily Cost</Text>
              <Text >${appGroupData.total_daily_cost}</Text>
            </div>

          <Text bold>App Group Labels</Text>
          <hr/>
          <div className={styles.grid}>
              {
                Object.entries(appGroupData.labels).map(k => (<>
                  <Text bold >{k[0]}</Text>
                  <Text >{k[1]}</Text>
                </>))
              }
          </div>
          <hr/>
          <div>
            <Button size="s" qualifier={<Search/>} primary>Open Kibana</Button>
            <Button size="s" qualifier={<SeriesSearch/>} primary>Open Katulampa</Button>
            <Button size="s" qualifier={<Tag/>} primary>Manage Labels</Button>
            <Button size="s" qualifier={<Tag/>} primary>Redact PII Data</Button>
            <Button size="s" qualifier={<Key/>} primary>Manage Access</Button>
            <Button size="s" qualifier={<Cloud/>} primary>Manage Infra</Button>
          </div>
        </Card>
      </div>
    </main>
  )
}
