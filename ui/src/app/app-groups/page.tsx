'use client'

import { useRouter, useSearchParams } from 'next/navigation'
import { useEffect, useState } from 'react';
import ReadOnlyPassword from '@/lib/readonly-password/ReadOnlyPassword';
import styles from './page.module.scss';
import { Button } from "@asphalt-react/button";
import { Card } from "@asphalt-react/card";
import { Cloud, Key, SeriesSearch, Search, Tag, Tick, Trash } from "@asphalt-react/iconpack";
import { Loader } from "@asphalt-react/loader";
import { Textfield } from "@asphalt-react/textfield";
import { ToggleSwitch } from "@asphalt-react/toggle-switch";
import { Text } from "@asphalt-react/typography";
import {
  Table,
  TableHead,
  TableBody,
  TableHeadRow,
  TableBodyRow,
  TableHeadCell,
  TableBodyCell,
} from "@asphalt-react/table"

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
          <div className={styles.appGroupInfo}>
              <Text bold size="s">Application Group Name</Text>
              <div><Textfield
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
                      <Tick />
                    </Button>
                  }
                />
              </div>

              <Text bold size="s">Log Retention Days</Text>
              <div><Textfield
                size="s"
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
              <Text bold size="s">App Group Secret</Text>
              <div><ReadOnlyPassword initialValue={appGroupData.secret}/></div>
              <Text bold size="s">TPS</Text>
              <div><Textfield
                size="s"
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
              <Text bold size="s">App Group Status</Text>
              <div className={styles.toggleSwitch}><ToggleSwitch
                  size="s"
                  on={appGroupData.is_active}
                  onToggle={({on}) => {
                    setAppGroupData({
                      ...appGroupData,
                      is_active: on,
                    })
                  }}
                /></div>
              <Text bold size="s">Redaction Status</Text>
              <div className={styles.toggleSwitch}><ToggleSwitch
                  size="s"
                  on={appGroupData.is_redaction_active}
                  onToggle={({on}) => {
                    setAppGroupData({
                      ...appGroupData,
                      is_redaction_active: on,
                    })
                  }}
                /></div>
              <Text bold size="s">Total Daily Log Ingested</Text>
              <Text size="s">{appGroupData.total_daily_log_ingested}</Text>
              <Text bold size="s">Total Daily Cost</Text>
              <Text size="s" >${appGroupData.total_daily_cost}</Text>
            </div>

          <Text bold size="s">App Group Labels</Text>
          <hr/>
          <div className={styles.appGroupInfo}>
              {
                Object.entries(appGroupData.labels).map(k => (<>
                  <Text bold size="s">{k[0]}</Text>
                  <Text size="s">{k[1]}</Text>
                </>))
              }
          </div>
          <hr/>
          <div className={styles.appGroupAction}>
            <Button underline={false} link size="xs" qualifier={<Search/>} primary>Open Kibana</Button>
            <Button underline={false} link size="xs" qualifier={<SeriesSearch/>} primary>Open Katulampa</Button>
            <Button underline={false} link size="xs" qualifier={<Tag/>} primary>Manage Labels</Button>
            <Button underline={false} link size="xs" qualifier={<Tag/>} primary>Redact PII Data</Button>
            <Button underline={false} link size="xs" qualifier={<Key/>} primary>Manage Access</Button>
            <Button underline={false} link size="xs" qualifier={<Cloud/>} primary>Manage Infra</Button>
          </div>
        </Card>
      </div>
      <div className={styles.container}>
      <Text bold size="l">Application List</Text>
        <Table contentFit>
          <TableHead>
            <TableHeadRow sticky>
              <TableHeadCell>Name</TableHeadCell>
              <TableHeadCell>Topic</TableHeadCell>
              <TableHeadCell>App Secret</TableHeadCell>
              <TableHeadCell>Retention Days</TableHeadCell>
              <TableHeadCell>TPS</TableHeadCell>
              <TableHeadCell>Status</TableHeadCell>
              <TableHeadCell>Created At</TableHeadCell>
              <TableHeadCell>Daily Log Ingested</TableHeadCell>
              <TableHeadCell>Daily Cost</TableHeadCell>
              <TableHeadCell>Actions</TableHeadCell>
            </TableHeadRow>
          </TableHead>
          <TableBody>
          {appGroupData.applications.map(app => <TableBodyRow>
            <TableBodyCell>{app.name}</TableBodyCell>
            <TableBodyCell>{app.topic_name}</TableBodyCell>
            <TableBodyCell>{app.secret}</TableBodyCell>
            <TableBodyCell>
              <div><Textfield
                size="xs"
                type="number"
                placeholder="Log Retention Days"
                value={app.log_retention_days}
                addOnEnd={
                  <Button icon nude compact system>
                    <Tick />
                  </Button>
                }
              /></div>
              </TableBodyCell>
            <TableBodyCell>
              <div><Textfield
                size="xs"
                type="number"
                placeholder="TPS"
                value={app.tps}
                addOnEnd={
                  <Button icon nude compact system>
                    <Tick />
                  </Button>
                }
              /></div>
              </TableBodyCell>
              <TableBodyCell>
                              <div className={styles.toggleSwitch}><ToggleSwitch
                  size="s"
                  on={app.is_active}
                /></div>

              </TableBodyCell>
            <TableBodyCell>{new Date(app.created_at).toString()}</TableBodyCell>
            <TableBodyCell>$ {app.total_daily_log_ingested}</TableBodyCell>
            <TableBodyCell>{app.total_daily_cost}</TableBodyCell>
            <TableBodyCell>

          <div className={styles.appAction}>
              <Button link icon size="xs" primary><Tag/></Button>
              <Button link icon size="xs" primary><Key/></Button>
              <Button link icon size="xs" danger><Trash/></Button>
              </div>
            </TableBodyCell>
          </TableBodyRow>
          )}
          </TableBody>
        </Table>
      </div>
    </main>
  )
}
