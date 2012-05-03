module ProjectsHelper
  def project_smart_path(project)
    if project.filename?
      project_name_path(project.filename)
    else
      project_path(project)
    end
  end
end
