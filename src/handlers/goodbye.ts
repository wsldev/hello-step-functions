export const handler = async (event: { body: any, statusCode: any }) => {
  const statusCode = event.statusCode
  const body = event.body.replace("Hello", "Good Bye")
    const response = {
    statusCode,
    originalBody: event.body,
    body,
    }
  return response
}