class EnemiesController < ApplicationController
    def index
      @enemies = Enemy.all
    end
  
    def show
      @enemy = Enemy.find(params[:id])
    end
  
    def new
      @enemy = Enemy.new
    end
  
    def create
      @enemy = Enemy.new(enemy_params)
      if @enemy.save
        redirect_to @enemy, notice: 'Enemy was successfully created.'
      else
        render :new
      end
    end
  
    def edit
      @enemy = Enemy.find(params[:id])
    end
  
    def update
      @enemy = Enemy.find(params[:id])
      if @enemy.update(enemy_params)
        redirect_to @enemy, notice: 'Enemy was successfully updated.'
      else
        render :edit
      end
    end
  
    def destroy
      @enemy = Enemy.find(params[:id])
      @enemy.destroy
      redirect_to enemies_url, notice: 'Enemy was successfully destroyed.'
    end
  
    private
  
    def enemy_params
      params.require(:enemy).permit(:name, :description, :health, :attack_points, :defense, :aggression_level, :room_id)
    end    
  end
  