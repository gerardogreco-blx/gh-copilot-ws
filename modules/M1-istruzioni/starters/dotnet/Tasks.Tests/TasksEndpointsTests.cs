using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

public class TasksEndpointsTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public TasksEndpointsTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetTasks_ReturnsEmptyList_Initially()
    {
        var response = await _client.GetAsync("/tasks");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var tasks = await response.Content.ReadFromJsonAsync<List<TaskApi.Tasks.TaskItem>>();
        Assert.NotNull(tasks);
        Assert.Empty(tasks);
    }

    [Fact]
    public async Task PostTask_CreatesTask_WithTodoStatus()
    {
        var response = await _client.PostAsJsonAsync("/tasks", new { title = "Test" });
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var created = await response.Content.ReadFromJsonAsync<TaskApi.Tasks.TaskItem>();
        Assert.NotNull(created);
        Assert.Equal("Test", created.Title);
        Assert.Equal("todo", created.Status);
    }
}
