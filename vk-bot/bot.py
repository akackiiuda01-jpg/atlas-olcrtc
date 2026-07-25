import vk_api
from vk_api.longpoll import VkLongPoll, VkEventType
from vk_api.keyboard import VkKeyboard, VkKeyboardColor

from config import VK_TOKEN, ADMIN_ID
import atlas

waiting_room = False


def keyboard():
    kb = VkKeyboard(one_time=False)

    kb.add_button("🔑 Показать ключ", color=VkKeyboardColor.PRIMARY)
    kb.add_line()
    kb.add_button("🆔 Изменить Room ID", color=VkKeyboardColor.POSITIVE)
    kb.add_line()
    kb.add_button("📊 Состояние Atlas", color=VkKeyboardColor.SECONDARY)

    return kb.get_keyboard()


vk_session = vk_api.VkApi(token=VK_TOKEN)
vk = vk_session.get_api()

longpoll = VkLongPoll(vk_session)

print("Atlas VK Bot started")

for event in longpoll.listen():

    if event.type != VkEventType.MESSAGE_NEW:
        continue

    if not event.to_me:
        continue

    if event.user_id != ADMIN_ID:
        continue

    text = event.text.strip()

    
    if waiting_room:
        atlas.set_room(text)

        vk.messages.send(
            user_id=event.user_id,
            random_id=0,
            message="✅ Room ID изменён.\nAtlas перезапущен."
        )

        waiting_room = False
        continue

    if text.lower() in ["меню", "start", "/start"]:

        vk.messages.send(
            user_id=event.user_id,
            random_id=0,
            message="Atlas Core",
            keyboard=keyboard()
        )

    elif text == "🔑 Показать ключ":

        vk.messages.send(
            user_id=event.user_id,
            random_id=0,
            message=atlas.get_key()
        )

    elif text == "📊 Состояние Atlas":

        status = atlas.status()

        vk.messages.send(
            user_id=event.user_id,
            random_id=0,
            message=f"Статус: {status}"
        )

    elif text == "🆔 Изменить Room ID":

        waiting_room = True

        vk.messages.send(
            user_id=event.user_id,
            random_id=0,
            message="Введите новый Room ID:"
        )
