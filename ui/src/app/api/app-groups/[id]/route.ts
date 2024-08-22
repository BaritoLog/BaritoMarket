import { NextResponse } from "next/server"

export async function generateStaticParams() {
	return [{id: "1"}]
}
export async function GET(
	request: Request,
	{ params }: { params: { id: string } },
) {
	return NextResponse.json({
		id: params.id,
		name: "liyue",
		log_retention_days: 7,
		secret: "foobar",
		cluster_name: "shina",
		capacity: "Production - Small - 16 - 24",
		tps: 5000,
		provisioning_status: "DEPLOYMENT_FINISHED",
		argo_sync_status: "Running",
		argo_sync_last_message: "waiting for completion of hook batch/Job/shina-elasticsearch-init",
		argo_application_health: "Healthy",
		is_active: true,
		is_redaction_active: false,
		total_daily_log_ingested: "3.26 TB",
		total_daily_cost: 100.24,
		labels: {
			"subteam/stream": "liyue",
			"team/pod": "liyue",
		},
		applications: [
			{
				name: "barito-prober-shina",
				topic_name: "barito-prober-shina",
				secret: "foobar",
				log_retention_days: 1,
				tps: 1,
				is_active: true,
				created_at: Date.now(),
				total_daily_log_ingested: "373 KB",
				total_daily_cost: 0.000010,
			},
			{
				name: "liyue",
				topic_name: "liyue",
				secret: "foobar",
				log_retention_days: 7,
				tps: 5000,
				is_active: false,
				created_at: Date.now(),
				total_daily_log_ingested: "3.26 TB",
				total_daily_cost: 100.24,
			},
		],
	},
	{status: 200})
}
