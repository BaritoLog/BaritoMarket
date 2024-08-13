/** @type {import('next').NextConfig} */
const nextConfig = {
	output: 'export',
	webpack: (config, context) => {
		config.watchOptions = {
			poll: 500,
			aggregateTimeout: 300,
		}
		return config
	},
};

export default nextConfig;
