ActiveAdmin.register Festival do

  permit_params :name, :year
  form do |f|
    f.input :name
    f.input :year
    f.input :city
    f.actions
  end

end
