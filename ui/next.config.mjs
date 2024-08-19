/** @type {import('next').NextConfig} */
const nextConfig = {
	output: 'export',
	// https://nextjs.org/docs/app/api-reference/next-config-js/trailingSlash
	trailingSlash: true,
	typescript: {
		// ignoring error on asphalt-react typings
		ignoreBuildErrors: true,
	},
	webpack: (config, context) => {
		config.watchOptions = {
			poll: 500,
			aggregateTimeout: 300,
		}
		return config
	},
};

export default nextConfig;
