ActiveAdmin.register City do
  permit_params :country, :name
  form do |f|
    f.inputs "City" do
      f.input :name
      f.input :country
      f.input :lat
      f.input :lng
    end
    f.actions
  end
end
