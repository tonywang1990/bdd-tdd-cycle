require 'spec_helper'

describe MoviesController do
  describe 'add Director' do
      before :each do
          @new_movie = double(Movie, title:"Star Wars", dirctor:"director", id:"1")
          Movie.stub(:find).with("1").and_return(@new_movie)
      end
      it 'should call update_attribute and redirect to new movie page' do
          @new_movie.should_receive(:update_attribute).and_return(true)
          put :update, {:id => "1", :movie => @new_movie}
          response.should redirect_to(movie_path(@new_movie))
      end
 
  end
end