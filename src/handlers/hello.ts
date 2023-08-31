export const handler = async (event: { name: any }) => {
  const { name } = event
    const response = {
    statusCode: 200,
    body: `Hello ${ name } !`
    }
  return response
}